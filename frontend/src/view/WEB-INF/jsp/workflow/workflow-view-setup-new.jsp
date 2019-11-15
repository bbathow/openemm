
<%@ page import="com.agnitas.emm.core.workflow.web.forms.WorkflowForm.WorkflowStatus" %>
<%@ page language="java" contentType="text/html; charset=utf-8" errorPage="/error.do" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-logic" prefix="logic" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="emm" uri="https://emm.agnitas.de/jsp/jsp/common" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="STATUS_OPEN" 		value="<%= WorkflowStatus.STATUS_OPEN %>" 		scope="page" />
<c:set var="STATUS_ACTIVE" 		value="<%= WorkflowStatus.STATUS_ACTIVE %>" 	scope="page" />
<c:set var="STATUS_INACTIVE" 	value="<%= WorkflowStatus.STATUS_INACTIVE %>" 	scope="page" />
<c:set var="STATUS_COMPLETE" 	value="<%= WorkflowStatus.STATUS_COMPLETE %>" 	scope="page" />
<c:set var="STATUS_TESTING" 	value="<%= WorkflowStatus.STATUS_TESTING %>" 	scope="page" />
<c:set var="STATUS_TESTED" 		value="<%= WorkflowStatus.STATUS_TESTED %>" 	scope="page" />

<emm:CheckLogon/>
<emm:Permission token="temp.beta"/>

<c:set var="agnNavigationKey" 		value="none" 									scope="request" />
<c:set var="agnNavHrefAppend" 		value="&workflowId=${workflowForm.workflowId}" 	scope="request" />
<c:set var="agnTitleKey" 			value="workflow.single" 						scope="request" />
<c:set var="sidemenu_active" 		value="Workflow" 								scope="request" />
<c:set var="isBreadcrumbsShown" 	value="true" 									scope="request" />
<c:set var="agnBreadcrumbsRootKey" 	value="Workflow" 								scope="request" />
<c:set var="agnHelpKey" 			value="help_workflow_edit" 						scope="request" />

<c:set var="workflowToggleTestingButtonEnabled" value="false" scope="request"/>
<c:set var="workflowToggleTestingButtonState" value="true" scope="request"/> <%-- Start/stop testing --%>

<c:choose>
    <c:when test="${workflowForm.status eq STATUS_OPEN || workflowForm.status eq STATUS_TESTED || workflowForm.status eq STATUS_INACTIVE}">
        <c:set var="workflowToggleTestingButtonEnabled" value="true" scope="request"/>
        <c:set var="workflowToggleTestingButtonState" value="true" scope="request"/> <%-- Start testing button --%>
    </c:when>
    <c:when test="${workflowForm.status eq STATUS_TESTING}">
        <c:set var="workflowToggleTestingButtonEnabled" value="true" scope="request"/>
        <c:set var="workflowToggleTestingButtonState" value="false" scope="request"/> <%-- Stop testing button --%>
    </c:when>
</c:choose>

<c:choose>
    <c:when test="${workflowForm.workflowId > 0 && not empty workflowForm.shortname}">
        <c:set var="agnSubtitleKey" 		value="workflow.single" scope="request" />
        <c:set var="sidemenu_sub_active" 	value="none" 			scope="request" />
        <c:set var="agnHighlightKey" 		value="workflow.single" scope="request" />

        <emm:instantiate var="agnBreadcrumbs" type="java.util.LinkedHashMap" scope="request">
            <emm:instantiate var="agnBreadcrumb" type="java.util.LinkedHashMap">
                <c:set target="${agnBreadcrumbs}" property="0" value="${agnBreadcrumb}"/>
                <c:set target="${agnBreadcrumb}" property="text" value="${workflowForm.shortname}"/>
            </emm:instantiate>
        </emm:instantiate>
    </c:when>
    <c:otherwise>
        <c:set var="agnSubtitleKey" 		value="workflow.new" 		scope="request" />
        <c:set var="sidemenu_sub_active" 	value="workflow.new" 		scope="request" />
        <c:set var="agnHighlightKey" 		value="workflow.new" 		scope="request" />
        <c:set var="agnHelpKey" 			value="help_workflow_new" 	scope="request" />

        <emm:instantiate var="agnBreadcrumbs" type="java.util.LinkedHashMap" scope="request">
            <emm:instantiate var="agnBreadcrumb" type="java.util.LinkedHashMap">
                <c:set target="${agnBreadcrumbs}" property="0" value="${agnBreadcrumb}"/>
                <c:set target="${agnBreadcrumb}" property="textKey" value="workflow.new"/>
            </emm:instantiate>
        </emm:instantiate>
    </c:otherwise>
</c:choose>

<jsp:useBean id="itemActionsSettings" class="java.util.LinkedHashMap" scope="request">
    <c:if test="${workflowForm.workflowId != 0 && workflowForm.shortname != ''}">
        <%--Actions dropdown menu --%>
        <jsp:useBean id="element2" class="java.util.LinkedHashMap" scope="request">
            <c:set target="${itemActionsSettings}" property="2" value="${element2}"/>

            <c:set target="${element2}" property="btnCls" value="btn btn-secondary btn-regular dropdown-toggle"/>
            <c:set target="${element2}" property="extraAttributes" value="data-toggle='dropdown'"/>
            <c:set target="${element2}" property="iconBefore" value="icon-wrench"/>
            <c:set target="${element2}" property="name"><bean:message key="action.Action"/></c:set>
            <c:set target="${element2}" property="iconAfter" value="icon-caret-down"/>

            <%--Dropdown items --%>
            <jsp:useBean id="optionList" class="java.util.LinkedHashMap" scope="request">
                <c:set target="${element2}" property="dropDownItems" value="${optionList}"/>

                <emm:ShowByPermission token="workflow.edit">
                    <%--Copy button --%>
                    <jsp:useBean id="option2" class="java.util.LinkedHashMap" scope="request">
                        <c:set target="${optionList}" property="2" value="${option2}"/>

                        <c:set target="${option2}" property="url" value="javascript:void(0)"/>
                        <c:set target="${option2}" property="extraAttributes" value="data-action='workflowCopyBtn'"/>
                        <c:set target="${option2}" property="icon" value="icon-copy"/>
                        <c:set target="${option2}" property="name">
                            <bean:message key="button.Copy"/>
                        </c:set>
                    </jsp:useBean>
                </emm:ShowByPermission>

                <%--Start test button --%>
                <c:if test="${workflowToggleTestingButtonEnabled}">
                    <c:choose>
                        <c:when test="${workflowToggleTestingButtonState}">
                            <c:set var="buttonText">
                                <bean:message key="button.workflow.testrun.start"/>
                            </c:set>
                        </c:when>
                        <c:otherwise>
                            <c:set var="buttonText">
                                <bean:message key="button.workflow.testrun.stop"/>
                            </c:set>
                        </c:otherwise>
                    </c:choose>
                    <c:set var="helperText">
                        <bean:message key="button.workflow.testrun.help"/>
                    </c:set>

                    <jsp:useBean id="option0" class="java.util.LinkedHashMap" scope="request">
                        <c:set target="${optionList}" property="0" value="${option0}"/>
                        <c:set target="${option0}" property="url" value="javascript:void(0)"/>
                        <c:set target="${option0}" property="extraAttributes" value="data-action='workflowTestBtn'  data-tooltip-help='${buttonText}' data-tooltip-help-text='${helperText}' "/>
                        <c:set target="${option0}" property="icon" value="icon-tasks"/>
                        <c:set target="${option0}" property="name">${buttonText}</c:set>
                    </jsp:useBean>
                </c:if>

                <%-- Fade in Statistics button --%>
                <jsp:useBean id="option1" class="java.util.LinkedHashMap" scope="request">
                    <c:set target="${optionList}" property="1" value="${option1}"/>
                    <c:set target="${option1}" property="url" value="javascript:void(0)"/>
                    <c:set target="${option1}" property="extraAttributes" value="data-action='workflowStatsBtn'"/>
                    <c:set target="${option1}" property="icon" value="icon-bar-chart-o"/>
                    <c:set target="${option1}" property="name">
                        <bean:message key="workflow.fadeInStatistics"/>
                    </c:set>
                </jsp:useBean>

                <emm:ShowByPermission token="workflow.delete">
                    <%--Delete button --%>
                    <jsp:useBean id="option3" class="java.util.LinkedHashMap" scope="request">
                        <c:set target="${optionList}" property="3" value="${option3}"/>
                        <c:set target="${option3}" property="url">
                            <html:rewrite page="/workflow/${workflowForm.workflowId}/delete.action"/>
                        </c:set>
                        <c:set target="${option3}" property="extraAttributes" value="data-confirm"/>
                        <c:set target="${option3}" property="icon" value="icon-trash-o"/>
                        <c:set target="${option3}" property="name">
                            <bean:message key="button.Delete"/>
                        </c:set>
                    </jsp:useBean>
                </emm:ShowByPermission>
            </jsp:useBean>
        </jsp:useBean>
    </c:if>

    <emm:ShowByPermission token="workflow.edit">
        <jsp:useBean id="element3" class="java.util.LinkedHashMap" scope="request">
            <c:set target="${itemActionsSettings}" property="3" value="${element3}"/>

            <c:set target="${element3}" property="btnCls" value="btn btn-regular btn-inverse"/>
            <c:set target="${element3}" property="extraAttributes" value="data-form-target='#workflowForm' data-form-set='method:save' data-action='workflowSaveBtn'"/>
            <c:set target="${element3}" property="iconBefore" value="icon-save"/>
            <c:set target="${element3}" property="name">
                <bean:message key="button.Save"/>
            </c:set>
        </jsp:useBean>
    </emm:ShowByPermission>
</jsp:useBean>
