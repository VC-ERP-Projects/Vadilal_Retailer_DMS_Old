<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="MachineClaimRegister.aspx.cs" Inherits="Reports_ClaimRegister" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">
        var ParentID = <% = ParentID%>;
        var CustType = <% =CustType%>;

        $(function () {
            ChangeReportFor('1');
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            ChangeReportFor('1');
        }

        function autoCompleteState_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            sender.set_contextKey(EmpID);
        }
        
        function autoCompleteSSDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            var reg = $('.txtRegion').is(":visible") ? $('.txtRegion').val().split('-').pop() : "0";

            sender.set_contextKey(reg + "-0-" + "0" + "-" + EmpID);
        }

        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            var reg = $('.txtRegion').is(":visible") ? $('.txtRegion').val().split('-').pop() : "0";

            var ss = "";
            if (CustType == 4)
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : ParentID;
            else
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : "0";
            sender.set_contextKey(reg+ "-0-" + "0" + "-" + ss + "-" + EmpID);
        }
       
        function acetxtDealerCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            var reg = $('.txtRegion').is(":visible") ? $('.txtRegion').val().split('-').pop() : "0";
            
            var ss = "";
            var dist = "";
            if (CustType == 4)
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : ParentID;
            else
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : "0";
            if (CustType == 2)
                dist = $('.txtCustCode').is(":visible") ? $('.txtCustCode').val().split('-').pop() : ParentID;
            else
                dist = $('.txtCustCode').is(":visible") ? $('.txtCustCode').val().split('-').pop() : "0";
            sender.set_contextKey(reg + "-0-0-" + ss + "-" + dist + "-" + EmpID);
        }
        
        function ChangeReportFor(ReportBy) {

            if ($('.ddlReportBy').val() == "4") {
                if (ReportBy == "2") {
                    $('.txtSSCode').val('');
                    $('.txtCustCode').val('');
                    $('.txtDealerCode').val('');
                }
                $('.divSS').removeAttr('style');
                $('.divDealer').attr('style', 'display:none;');
            }
            else if ($('.ddlReportBy').val() == "2") {
                if (ReportBy == "2") {
                    $('.txtSSCode').val('');
                    $('.txtCustCode').val('');
                    $('.txtDealerCode').val('');
                }
                $('.divSS').attr('style', 'display:none;');
                $('.divDealer').removeAttr('style');
            }
        }

        function ClearOtherConfig() {
            if ($(".txtCode").length > 0) {
                $(".txtPlant").val('');
                $(".txtRegion").val('');
                $(".txtSSDistCode").val('');
                $(".txtCustCode").val('');
                $(".txtdealer").val('');
            }
        }

        function ClearOtherDistConfig() {
            if ($(".txtCustCode").length > 0) {
                $(".txtdealer").val('');
            }
        }

        function ClearOtherSSConfig() {
            if ($(".txtSSDistCode").length > 0) {
                $(".txtCustCode").val('');
            }
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:label id="lblFromDate" runat="server" text="From Date" cssclass="input-group-addon"></asp:label>
                        <asp:textbox id="txtFromDate" runat="server" tabindex="1" maxlength="10" onkeyup="return ValidateDate(this);" cssclass="fromdate form-control"></asp:textbox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:label id="lblToDate" runat="server" text="To Date" cssclass="input-group-addon"></asp:label>
                        <asp:textbox id="txtToDate" runat="server" tabindex="2" maxlength="10" onkeyup="return ValidateDate(this);" cssclass="todate form-control"></asp:textbox>
                    </div>
                </div>
                <div class="col-lg-4" id="divEmpCode" runat="server">
                    <div class="input-group form-group">
                        <asp:label id="lblCode" runat="server" text="Employee" cssclass="input-group-addon"></asp:label>
                        <asp:textbox id="txtCode" onchange="ClearOtherConfig()" runat="server" cssclass="form-control txtCode" style="background-color: rgb(250, 255, 189);" tabindex="3"></asp:textbox>
                        <asp:autocompleteextender onclientshown="resetPosition" completionlistcssclass="CompletionListClass" id="acettxtEmployeeCode" runat="server" servicepath="../Service.asmx"
                            usecontextkey="true" servicemethod="GetEmployeeList" minimumprefixlength="1" completioninterval="10"
                            enablecaching="false" completionsetcount="1" targetcontrolid="txtCode">
                        </asp:autocompleteextender>
                    </div>
                </div>
                <div class="col-lg-4" id="divRegion" runat="server">
                    <div class="input-group form-group">
                        <asp:label id="lblRegion" runat="server" text='Region' cssclass="input-group-addon"></asp:label>
                        <asp:textbox id="txtRegion" cssclass="txtRegion form-control" tabindex="4" runat="server" style="background-color: rgb(250, 255, 189);"></asp:textbox>
                        <asp:autocompleteextender onclientshown="resetPosition" completionlistcssclass="CompletionListClass" id="AutoCompleteExtender1" runat="server" servicemethod="GetStatesCurrHierarchy"
                            servicepath="../Service.asmx" minimumprefixlength="1" completioninterval="10" enablecaching="false" completionsetcount="1" onclientpopulating="autoCompleteState_OnClientPopulating"
                            targetcontrolid="txtRegion" usecontextkey="True">
                        </asp:autocompleteextender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:label id="lblCustomerType" runat="server" text="Customer Type" cssclass="input-group-addon"></asp:label>
                        <asp:dropdownlist id="ddlReportBy" runat="server" cssclass="ddlReportBy form-control" onchange="ChangeReportFor('2');" tabindex="5">
                            <asp:ListItem Text="Super Stockist" Value="4" />
                            <asp:ListItem Text="Distributor" Value="2" Selected="True" />
                        </asp:dropdownlist>
                    </div>
                </div>
                <div class="col-lg-4 divSS">
                    <div class="input-group form-group divSS" id="divSS" runat="server">
                        <asp:label id="lblSSCustomer" runat="server" text="Super Stockist" cssclass="input-group-addon"></asp:label>
                        <asp:textbox id="txtSSDistCode" onchange="ClearOtherSSConfig()" runat="server" tabindex="6" style="background-color: rgb(250, 255, 189);" cssclass="txtSSDistCode form-control" autocomplete="off"></asp:textbox>
                        <asp:autocompleteextender onclientshown="resetPosition" completionlistcssclass="CompletionListClass" id="aceSStxtName" runat="server" servicepath="~/Service.asmx"
                            usecontextkey="true" servicemethod="GetSSCurrHierarchy" minimumprefixlength="1" completioninterval="10" onclientpopulating="autoCompleteSSDistriCode_OnClientPopulating"
                            enablecaching="false" completionsetcount="1" targetcontrolid="txtSSDistCode">
                        </asp:autocompleteextender>
                    </div>
                </div>
                <div class="col-lg-4 divDistributor">
                    <div class="input-group form-group divDistributor" id="divDistributor" runat="server">
                        <asp:label id="lblCustomer" runat="server" text="Distributor" cssclass="input-group-addon"></asp:label>
                        <asp:textbox id="txtCustCode" onchange="ClearOtherDistConfig()" runat="server" tabindex="6" cssclass="txtCustCode form-control" style="background-color: rgb(250, 255, 189);" autocomplete="off"></asp:textbox>
                        <asp:autocompleteextender onclientshown="resetPosition" completionlistcssclass="CompletionListClass" id="acetxtName" runat="server" servicepath="~/Service.asmx"
                            usecontextkey="true" servicemethod="GetDistCurrHierarchy" minimumprefixlength="1" completioninterval="10" onclientpopulating="autoCompleteDistriCode_OnClientPopulating"
                            enablecaching="false" completionsetcount="1" targetcontrolid="txtCustCode">
                        </asp:autocompleteextender>
                    </div>
                </div>
                <div class="col-lg-4 divDealer">
                    <div class="input-group form-group divDealer" id="divDealer" runat="server">
                        <asp:label id="lbldealer" runat="server" text="Dealer" cssclass="input-group-addon"></asp:label>
                        <asp:textbox id="txtdealer" runat="server" tabindex="6" cssclass="txtdealer form-control" style="background-color: rgb(250, 255, 189);" autocomplete="off"></asp:textbox>
                        <asp:autocompleteextender onclientshown="resetPosition" completionlistcssclass="CompletionListClass" id="acetxtdealer" runat="server" servicepath="~/Service.asmx"
                            usecontextkey="true" servicemethod="GetDealerFromCurrHierarchy" minimumprefixlength="1" completioninterval="10" onclientpopulating="acetxtDealerCode_OnClientPopulating"
                            enablecaching="false" completionsetcount="1" targetcontrolid="txtdealer">
                        </asp:autocompleteextender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:button id="btnGenerat" runat="server" text="Generate" tabindex="7" cssclass="btn btn-default" onclick="btnGenerat_Click" />
                    </div>
                </div>
            </div>
        </div>
        <iframe id="ifmMaterialPurchase" style="width: 100%" class="embed-responsive-item" runat="server" onload="ifmMaterialPurchase_Load"></iframe>
    </div>
</asp:Content>

