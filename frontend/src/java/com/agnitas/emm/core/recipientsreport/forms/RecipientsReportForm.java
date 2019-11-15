/*

    Copyright (C) 2019 AGNITAS AG (https://www.agnitas.org)

    This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
    You should have received a copy of the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

*/

package com.agnitas.emm.core.recipientsreport.forms;

import com.agnitas.emm.core.recipientsreport.bean.RecipientsReport;
import org.agnitas.web.forms.FormDateTime;
import org.agnitas.web.forms.PaginationForm;

public class RecipientsReportForm extends PaginationForm {

    private RecipientsReport.RecipientReportType[] filterTypes;

    private FormDateTime filterDateStart = new FormDateTime();

    private FormDateTime filterDateFinish = new FormDateTime();

    public RecipientsReport.RecipientReportType[] getFilterTypes() {
        return filterTypes;
    }

    public void setFilterTypes(RecipientsReport.RecipientReportType[] filterTypes) {
        this.filterTypes = filterTypes;
    }

    public FormDateTime getFilterDateStart() {
        return filterDateStart;
    }

    public FormDateTime getFilterDateFinish() {
        return filterDateFinish;
    }
}
