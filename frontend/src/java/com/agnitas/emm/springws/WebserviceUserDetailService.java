/*

    Copyright (C) 2019 AGNITAS AG (https://www.agnitas.org)

    This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
    You should have received a copy of the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

*/

package com.agnitas.emm.springws;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import org.agnitas.dao.impl.BaseDaoImpl;
import org.agnitas.dao.impl.mapper.StringRowMapper;
import org.agnitas.emm.core.commons.util.ConfigService;
import org.agnitas.emm.core.commons.util.ConfigValue;
import org.agnitas.emm.springws.security.authorities.AllEndpointsAuthority;
import org.agnitas.emm.springws.security.authorities.CompanyAuthority;
import org.agnitas.emm.springws.security.authorities.EndpointAuthority;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Required;
import org.springframework.dao.DataAccessException;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;

public class WebserviceUserDetailService extends BaseDaoImpl implements UserDetailsService {
    /**
     * The logger.
     */
    private static final transient Logger logger = Logger.getLogger(WebserviceUserDetailService.class);

    private WebservicePasswordEncryptor webservicePasswordEncryptor;
    private ConfigService configService;

    @Required
    public final void setWebservicePasswordEncryptor(final WebservicePasswordEncryptor webservicePasswordEncryptor) {
        this.webservicePasswordEncryptor = Objects.requireNonNull(webservicePasswordEncryptor, "Webservice password encryptor is null");
    }
    
    @Required
    public final void setConfigService(final ConfigService service) {
    	this.configService = Objects.requireNonNull(service, "Config service is null");
    }

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException, DataAccessException {
        final String usersByUsernameQuery = "SELECT w.password_encrypted, w.company_id FROM webservice_user_tbl w, company_tbl c WHERE w.username = ? AND w.active = 1 AND w.company_id=c.company_id and c.status='active'";
        
        final List<Map<String, Object>> result = select(logger, usersByUsernameQuery, username);
        if (result.size() == 0) {
            throw new UsernameNotFoundException("Username " + username + " not found");
        } else {
            final Map<String, Object> userRow = result.get(0);
            final int companyID = ((Number) userRow.get("company_id")).intValue();
            final String encryptedPasswordBase64 = (String) userRow.get("password_encrypted");

            // Decrypt the encrypted password
            final String password = decryptPassword(encryptedPasswordBase64, username);
           
            final Collection<GrantedAuthority> grantedAuthorities = loadGrantedAuthorities(companyID, username);
            
            return new User(username, password, true, true, true, true, grantedAuthorities);
        }
    }
    
    private final String decryptPassword(final String encryptedPasswordBase64, final String username) throws UsernameNotFoundException {
        try {
            return webservicePasswordEncryptor.decrypt(username, encryptedPasswordBase64);
        } catch (Exception e) {
            throw new UsernameNotFoundException("Userpassword of user " + username + " cannot be decrypted");
        }
    }
    
    private final boolean areWebservicePermissionsEnabled(final int companyID) {
    	return this.configService.getBooleanValue(ConfigValue.WebserviceEnablePermissions, companyID);
    }
    
    private final List<GrantedAuthority> loadGrantedAuthorities(final int companyID, final String username) {
        final List<GrantedAuthority> grantedAuthorities = new ArrayList<>();
        
        if(areWebservicePermissionsEnabled(companyID)) {
        	final String sql = 
        			"SELECT DISTINCT endpoint " + 
        			"FROM (" + 
        			"SELECT endpoint FROM webservice_permission_tbl WHERE username=? " + 
        			"UNION " + 
        			"SELECT endpoint FROM webservice_perm_group_perm_tbl perms, webservice_user_group_tbl groups " + 
        			"WHERE groups.username=? AND perms.group_ref=groups.group_ref  " + 
        			") endpoints";
        	
        	final List<String> permissions = select(logger, sql, new StringRowMapper(), username, username);
        	permissions.forEach(permission -> grantedAuthorities.add(new EndpointAuthority(permission)));
        } else {
        	grantedAuthorities.add(AllEndpointsAuthority.INSTANCE);
        }
        
        grantedAuthorities.add(new CompanyAuthority(companyID));
        
        return grantedAuthorities;
    }
}
