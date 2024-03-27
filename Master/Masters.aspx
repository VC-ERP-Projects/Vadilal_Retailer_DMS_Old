<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="Masters.aspx.cs" Inherits="Master_Masters" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">
        function _btnCheck() {
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            return $('._masterForm').data('bootstrapValidator').isValid();
        }
        $(document).ready(function () {
            $(".allownumericwithdecimal").keydown(function (e) {
                // Allow: backspace, delete, tab, escape, enter
                if ($.inArray(e.keyCode, [46, 8, 9, 27, 13, 110, 190, 86, 67]) !== -1 ||
                    // Allow: Ctrl+A, Command+A
                    ((e.keyCode == 65 || e.keyCode == 86 || e.keyCode == 67) && (e.ctrlKey === true || e.metaKey === true)) ||
                    // Allow: home, end, left, right, down, up
                    (e.keyCode >= 35 && e.keyCode <= 40)) {
                    // let it happen, don't do anything

                    var myval = $(this).val();
                    if (myval != "") {
                        if (isNaN(myval)) {
                            $(this).val('');
                            e.preventDefault();
                            return false;
                        }
                    }
                    return;
                }
                // Ensure that it is a number and stop the keypress
                if ((e.shiftKey || (e.keyCode < 48 || e.keyCode > 57)) && (e.keyCode < 96 || e.keyCode > 105)) {
                    e.preventDefault();
                }
            });
        });

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div style="margin-left: 15px">
        <input type="checkbox" name="onoffswitch" class="_auchk" onchange="javascript: setTimeout('__doPostBack(\'\',\'\')', 0)" data-size="large" data-on-text="Add" data-off-text="Update" clientidmode="Static" id="chkMode" runat="server" checked="checked" onserverchange="chkMode_Checked" />
    </div>
    <div class="panel panel-default">
        <div class="panel-body _masterForm">
            <div class="row" style="margin-bottom: 0px">
                <div class="col-lg-4">
                    <div class="input-group form-group" style="margin-bottom: 0px">
                        <asp:Label ID="lblModule" runat="server" Text="Module" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlModule" TabIndex="1" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlModule_SelectedIndexChanged" CssClass="form-control">
                        </asp:DropDownList>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblNo" runat="server" Text="Code" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtNo" TabIndex="2" runat="server" OnTextChanged="txtNo_TextChanged" autocomplete="off" AutoPostBack="true" CssClass="form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="ACEtxtName" runat="server" ServiceMethod="GetMasters"
                            ServicePath="../WebService.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtNo" UseContextKey="True" Enabled="false">
                        </asp:AutoCompleteExtender>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblMst" runat="server" Text="Select" Visible="false" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlMst" TabIndex="3" runat="server" Visible="false" CssClass="form-control"></asp:DropDownList>
                        <asp:Label ID="lblExName" runat="server" Text="Sort Name" CssClass="input-group-addon" Visible="false"></asp:Label>
                        <asp:TextBox ID="txtExName" TabIndex="4" runat="server" CssClass="form-control" Visible="false"></asp:TextBox>
                        <asp:Label Text="Document Type" runat="server" ID="lblDoctype" Visible="false" CssClass="input-group-addon" />
                        <asp:DropDownList runat="server" ID="ddlDocType" TabIndex="5" AutoPostBack="True" OnSelectedIndexChanged="ddlDocType_SelectedIndexChanged" Visible="false" CssClass="form-control" data-bv-callback="true" data-bv-callback-message="Select Value" data-bv-callback-callback="_ddvalCheck">
                            <asp:ListItem Text="---Select---" Value="0" />
                            <asp:ListItem Text="FeedBack" Value="F" />
                            <asp:ListItem Text="Security Question" Value="S" />
                        </asp:DropDownList>
                        <asp:Label Text="Select Type" runat="server" ID="lblexptype" Visible="false" CssClass="input-group-addon" />
                        <asp:DropDownList runat="server" ID="ddlexptype" Visible="false" CssClass="form-control">
                            <asp:ListItem Text="Expense and Travel Type" Value="T" />
                            <asp:ListItem Text="Asset Type" Value="A" />
                        </asp:DropDownList>
                        <asp:Label ID="lblGrpSort" runat="server" Text="Sort Order" CssClass="input-group-addon" Visible="false"></asp:Label>
                        <asp:TextBox ID="txtEmpSortOrder" TabIndex="4" runat="server" CssClass="allownumericwithdecimal form-control" Visible="false"></asp:TextBox>
                        <asp:Label Text="Task Type" runat="server" ID="lblTaskType" Visible="false" CssClass="input-group-addon" />
                        <asp:DropDownList runat="server" ID="ddlTaskType" TabIndex="11" DataSourceID="edsTaskType" DataTextField="TaskTypeName" DataValueField="TaskTypeID" AppendDataBoundItems="true" Visible="false" CssClass="form-control">
                        </asp:DropDownList>
                        <asp:EntityDataSource ID="edsTaskType" runat="server" ConnectionString="name=DDMSEntities"
                            Where="it.Active = true" DefaultContainerName="DDMSEntities"
                            EnableFlattening="False" EntitySetName="OTTies">
                        </asp:EntityDataSource>
                        <asp:Label Text="Task Reason Type" runat="server" ID="lblTaskReason" Visible="false" CssClass="input-group-addon" />
                        <asp:DropDownList runat="server" ID="ddlTaskReason" TabIndex="9" Visible="false" CssClass="form-control">
                            <asp:ListItem Text="Planned" Value="P" />
                            <asp:ListItem Text="UnPlanned" Value="U" />
                        </asp:DropDownList>
                        <asp:Label runat="server" ID="lblEmpGroup" Text="Employee Group" Visible="false" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlEGroup" Visible="false" CssClass="ddlEGroup form-control" TabIndex="2" DataSourceID="edsEmpGroup" DataTextField="EmpGroupName" DataValueField="EmpGroupID" AppendDataBoundItems="true">
                        </asp:DropDownList>
                        <asp:EntityDataSource ID="edsEmpGroup" runat="server" ConnectionString="name=DDMSEntities"
                            Where="it.Active = true and it.ParentID = 1000010000000000" DefaultContainerName="DDMSEntities"
                            EnableFlattening="False" EntitySetName="OGRPs">
                        </asp:EntityDataSource>
                        
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblItemGroupSubGroupPhoto" Visible="false" runat="server" />
                        <asp:AsyncFileUpload UploaderStyle="Traditional" ID="afuItemGroupSubGroupPhoto" Visible="false" ClientIDMode="AutoID" runat="server"
                            OnUploadedComplete="afuItemGroupSubGroupPhoto_UploadedComplete" Style="margin-left: 29%; margin-top: 3%" CompleteBackColor="White" CssClass="imageUploaderField" />
                        <asp:Label ID="lblBannerPhoto" runat="server" Visible="false" />
                        <asp:AsyncFileUpload UploaderStyle="Traditional" ID="afuBannerPhoto" Visible="false" ClientIDMode="AutoID" runat="server"
                            OnUploadedComplete="afuBannerPhoto_UploadedComplete" Style="margin-left: 29%; margin-top: 3%" CompleteBackColor="White" CssClass="imageUploaderField" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblName" runat="server" Text="Name" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtName" runat="server" TabIndex="7" CssClass="form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>

                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Code" CssClass="input-group-addon" Visible="false"></asp:Label>
                        <asp:TextBox ID="txtCode" runat="server" TabIndex="8" CssClass="form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required" Visible="false"></asp:TextBox>
                        <asp:Label Text="Reason Type" runat="server" ID="lblResType" Visible="false" CssClass="input-group-addon" />
                        <asp:DropDownList runat="server" ID="ddlResType" TabIndex="6" AutoPostBack="False" Visible="false" CssClass="form-control" data-bv-callback="true" data-bv-callback-message="Select Value" data-bv-callback-callback="_ddvalCheck">
                            <asp:ListItem Text="---Select---" Value="0" />
                            <asp:ListItem Text="Sales Return" Value="R" />
                            <asp:ListItem Text="Wastage" Value="W" />
                            <asp:ListItem Text="Auto Wastage" Value="X" />
                            <asp:ListItem Text="Sales Scheme" Value="S" />
                            <asp:ListItem Text="Purchase" Value="I" />
                            <asp:ListItem Text="Purchase Return" Value="P" />
                            <asp:ListItem Text="Order From" Value="T" />
                        </asp:DropDownList>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label Text="Type" runat="server" ID="lblType" Visible="false" CssClass="input-group-addon" />
                        <asp:DropDownList runat="server" ID="ddlType" TabIndex="9" Visible="false" CssClass="form-control" data-bv-callback="true" data-bv-callback-message="Select Value" data-bv-callback-callback="_ddvalCheck">
                            <asp:ListItem Text="---Select---" Value="0" />
                            <asp:ListItem Text="Products" Value="P" />
                            <asp:ListItem Text="Services" Value="S" />
                            <asp:ListItem Text="Others" Value="O" />
                        </asp:DropDownList>
                        <asp:Label ID="lblInMins" runat="server" Text="In City Mins" CssClass="input-group-addon" Visible="false"></asp:Label>
                        <asp:TextBox ID="txtInMins" runat="server" TabIndex="7" CssClass="allownumericwithdecimal form-control" data-bv-notempty="true" Visible="false" data-bv-notempty-message="Field is required"></asp:TextBox>
                        <asp:Label Text="Price List" runat="server" ID="lblPriceList" Visible="false" CssClass="input-group-addon" />
                        <asp:DropDownList runat="server" ID="ddlPriceList" TabIndex="10" DataSourceID="edsPriceList" DataTextField="Name" DataValueField="PriceListID" AppendDataBoundItems="true" Visible="false" CssClass="form-control">
                            <asp:ListItem Text="---Select---" Value="0" />
                        </asp:DropDownList>
                        <asp:EntityDataSource ID="edsPriceList" runat="server" ConnectionString="name=DDMSEntities"
                            Where="it.Active = true" DefaultContainerName="DDMSEntities"
                            EnableFlattening="False" EntitySetName="OIPLs">
                        </asp:EntityDataSource>
                        <asp:Label runat="server" ID="lblProbType" Text="Problem Type" Visible="false" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlProbType" Visible="false" CssClass="ddlProbType form-control" TabIndex="2" DataSourceID="edsProbType" DataTextField="ProbemName" DataValueField="ProblemID" AppendDataBoundItems="true">
                        </asp:DropDownList>
                        <asp:EntityDataSource ID="edsProbType" runat="server" ConnectionString="name=DDMSEntities"
                            Where="it.Active = true" DefaultContainerName="DDMSEntities"
                            EnableFlattening="False" EntitySetName="OPLMs">
                        </asp:EntityDataSource>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblIsActive" runat="server" Text="Is Active" CssClass="input-group-addon"></asp:Label>
                        <asp:CheckBox ID="chkIsActive" runat="server" TabIndex="11" Checked="true" CssClass="form-control" />
                    </div>
                    <div class="input-group form-group">
                        <asp:Label Text="Campaign" runat="server" ID="lblCampaign" Visible="false" CssClass="input-group-addon" />
                        <asp:DropDownList runat="server" ID="ddlCampaign" TabIndex="12" DataSourceID="edsCampaign" DataTextField="CampaignName" DataValueField="CampaignID" AppendDataBoundItems="true" Visible="false" CssClass="form-control">
                            <asp:ListItem Text="---Select---" Value="0" />
                        </asp:DropDownList>
                        <asp:EntityDataSource ID="edsCampaign" runat="server" ConnectionString="name=DDMSEntities"
                            Where="it.Active = true and it.ParentID = @ParentID" DefaultContainerName="DDMSEntities"
                            EnableFlattening="False" EntitySetName="OCMPs">
                            <WhereParameters>
                                <asp:SessionParameter Name="ParentID" SessionField="ParentID" DbType="Decimal" />
                            </WhereParameters>
                        </asp:EntityDataSource>
                        <asp:Label ID="lblOutMins" runat="server" Text="Out City Mins" CssClass="input-group-addon" Visible="false"></asp:Label>
                        <asp:TextBox ID="txtOutMins" runat="server" TabIndex="7" CssClass="allownumericwithdecimal form-control" data-bv-notempty="true" Visible="false" data-bv-notempty-message="Field is required"></asp:TextBox>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCreatedBy" runat="server" Text="Created By" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCreatedBy" Enabled="false" runat="server" CssClass="form-control txtCreatedBy" Style="font-size: small"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCreatedTime" runat="server" Text="Created Time" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCreatedTime" Enabled="false" runat="server" CssClass="form-control txtCreatedTime" Style="font-size: small"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblUpdatedBy" runat="server" Text="Updated By" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtUpdatedBy" Enabled="false" runat="server" CssClass="form-control txtUpdatedBy" Style="font-size: small"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblUpdatedtime" runat="server" Text="Updated Time" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtUpdatedTime" Enabled="false" runat="server" CssClass="form-control txtUpdatedTime" Style="font-size: small"></asp:TextBox>
                    </div>
                </div>
            </div>
            <asp:Button ID="btnSubmit" runat="server" Text="Submit" CssClass="btn btn-default" TabIndex="13" OnClientClick="return _btnCheck();" OnClick="btnSubmitClick" />
            <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-default" TabIndex="14" UseSubmitBehavior="false" CausesValidation="false"
                OnClick="btnCancelClick" />
        </div>
    </div>
</asp:Content>
