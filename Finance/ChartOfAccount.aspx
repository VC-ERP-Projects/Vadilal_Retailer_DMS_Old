<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="ChartOfAccount.aspx.cs" Inherits="Finance_ChartOfAccount" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">

        function _btnCheck() {
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            return $('._masterForm').data('bootstrapValidator').isValid();
        }

        function setname(txt) {
            var Data = $(txt).val().split('-');
            $('.txtGLName').val(Data[1].trim());
        }
        $(function () {
            Relaod();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            Relaod();
        }
        function Relaod() {
            $('embed').css('height', '450px');
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">

    <div style="margin-left: 15px">
        <input type="checkbox" name="onoffswitch" class="_auchk" style="margin-bottom: 10px" onchange="javascript: setTimeout('__doPostBack(\'\',\'\')', 0)" data-size="large" data-on-text="Add" data-off-text="Update" clientidmode="Static" id="chkMode" runat="server" checked="checked" onserverchange="chkMode_Checked" />
    </div>
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row">
                <div class="col-lg-6">
                    <div class="row _masterForm">
                        <div class="col-lg-12">
                            <div class="input-group form-group" runat="server" id="lblGLAccCode" visible="false" style="margin-top: 0px">
                                <asp:Label Text="Select GLAcc" runat="server" CssClass="input-group-addon" />
                                <asp:TextBox runat="server" ID="txtGLAccCode" AutoPostBack="true" OnTextChanged="GLCode_OnTextChanged" CssClass="form-control" />
                                <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtGLCode" runat="server" ServicePath="../WebService.asmx"
                                    UseContextKey="true" ServiceMethod="GetGLAccount" MinimumPrefixLength="1" CompletionInterval="10"
                                    Enabled="false" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtGLAccCode">
                                </asp:AutoCompleteExtender>
                            </div>
                            <div class="input-group form-group" style="margin-top: 0px">
                                <asp:Label runat="server" ID="lblGLGroupName" Text="GL Group" CssClass="input-group-addon"></asp:Label>
                                <asp:DropDownList runat="server" ID="ddlGLGroupName" OnSelectedIndexChanged="ddlGLGroupName_SelectedIndexChanged" CssClass="form-control" AutoPostBack="true" DataTextField="GLAccGroupName" DataValueField="GLAccGroupID" DataSourceID="edsGLGroup" data-bv-callback="true" data-bv-callback-message="Select Value" data-bv-callback-callback="_ddvalCheck">
                                </asp:DropDownList>
                                <asp:EntityDataSource ID="edsGLGroup" runat="server" ConnectionString="name=DDMSEntities"
                                    DefaultContainerName="DDMSEntities" EnableFlattening="False" EntitySetName="GLAGs" Where="it.Active = true and it.ParentID = @ParentID">
                                    <WhereParameters>
                                        <asp:SessionParameter Name="ParentID" SessionField="ParentID" DbType="Decimal" />
                                    </WhereParameters>
                                </asp:EntityDataSource>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label runat="server" ID="lblParentGL" Text="Parent GL" CssClass="input-group-addon"></asp:Label>
                                <asp:DropDownList runat="server" ID="ddlParentGL" OnSelectedIndexChanged="ddlParentGL_SelectedIndexChanged" CssClass="form-control" AutoPostBack="true" DataTextField="GLAccName" DataValueField="GLAccID">
                                </asp:DropDownList>
                            </div>
                            <div class="input-group form-group" runat="server" id="lblACName" visible="false">
                                <asp:Label runat="server" Text="A/C Name" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtACName" runat="server" onchange="setname(this);" CssClass="form-control"></asp:TextBox>
                                <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtGL" runat="server" ServicePath="../WebService.asmx" 
                                    UseContextKey="true" ServiceMethod="GetGLCustomer" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtACName">
                                </asp:AutoCompleteExtender>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblGLName" runat="server" Text="GL Name" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtGLName" CssClass="txtGLName form-control" runat="server" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblCreditDays" runat="server" Text="Credit Days" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtCreditDays" runat="server" CssClass="form-control"></asp:TextBox>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="Label1" runat="server" Text="Credit Limit" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtCrrditLimit" runat="server" CssClass="form-control"></asp:TextBox>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblGLAmount" runat="server" Text="GL Amount" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtGLAmount" runat="server" placeholder="INR" Enabled="false" CssClass="form-control"></asp:TextBox>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label runat="server" ID="lblIsActive" Text="Is Active" CssClass="input-group-addon"></asp:Label>
                                <asp:CheckBox ID="chkIsActive" runat="server" Checked="true" CssClass="form-control" />
                            </div>
                            <div class="input-group form-group">
                                <asp:Label runat="server" ID="lblNotes" Text="Notes" CssClass="input-group-addon"> </asp:Label>
                                <asp:TextBox runat="server" ID="txtNotes" TextMode="MultiLine" CssClass="form-control"></asp:TextBox>
                            </div>
                        </div>
                    </div>
                    <asp:Button ID="btnSubmit" CssClass="btn btn-default" runat="server"
                        Text="Submit" OnClick="btnSubmit_Click" OnClientClick="return _btnCheck();" />
                    <asp:Button ID="btnCancel" CssClass="btn btn-default" UseSubmitBehavior="false" CausesValidation="false" runat="server"
                        Text="Cancel" OnClick="btnCancel_Click" />
                </div>
                <div class="col-lg-6">
                    <asp:Button Text="Load Report" CssClass="btn btn-default" ID="btnReport" runat="server" OnClick="btnReport_Click" />

                    <iframe id="ChartofAccount" class="embed-responsive-item" style="margin-top: 1.5%; width: 100%; height: 430px" runat="server"></iframe>

                </div>
            </div>

        </div>
    </div>


</asp:Content>

