<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="MasterDemo.aspx.cs" Inherits="Master_MasterDemo" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">
        function autoCompleteMatGroup_OnClientPopulating(sender, args) {
            var key = $('.txtGroup').val().split('-')[0];
            sender.set_contextKey(key);
        }

        function autoCompleteMatName_OnClientPopulating(sender, args) {
            var key = $('.txtSubGroup').val().split('-')[0];
            sender.set_contextKey(key);
        }

        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            var reg = $('.txtRegion').val().split('-')[0];

            var plt = $('.txtPlant').val().split('-')[0];

            sender.set_contextKey(reg + "-" + plt);
        }

        function autoCompletePlant_OnClientPopulating(sender, args) {
            var key = $('.txtRegion').val().split('-')[0];
            sender.set_contextKey(key);
        }


        function autoCompleteDealerCode_OnClientPopulating(sender, args) {

            if ($('.txtDistributor').val() != undefined) {
                var key = $('.txtDistributor').val().split('-')[2];
                if (key != undefined)
                    sender.set_contextKey(key);
            }
        }
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
            <div class="row">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblNo" runat="server" Text="Code" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtNo" TabIndex="2" runat="server" OnTextChanged="txtNo_TextChanged" autocomplete="off" AutoPostBack="true" CssClass="form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="ACEtxtName" runat="server" ServiceMethod="GetMasters"
                            ServicePath="../WebService.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtNo" UseContextKey="True" Enabled="false">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblName" runat="server" Text="Name" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtName" runat="server" TabIndex="7" CssClass="form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblRegion" runat="server" Text='Region' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtRegion" CssClass="txtRegion form-control" runat="server" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender1" runat="server" ServiceMethod="GetStateNames"
                            ServicePath="../WebService.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1"
                            TargetControlID="txtRegion" UseContextKey="True">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblPlant" runat="server" Text='Plant' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtPlant" runat="server" Style="background-color: rgb(250, 255, 189);" CssClass="txtPlant form-control"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender2" runat="server" ServiceMethod="GetPlant"
                            ServicePath="../WebService.asmx" OnClientPopulating="autoCompletePlant_OnClientPopulating" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtPlant" UseContextKey="True">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4" id="divCustGroup">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCustGroup" Text="Customer Group" CssClass="input-group-addon" runat="server" />
                        <asp:TextBox runat="server" ID="txtCustGroup" CssClass="txtCustGroup form-control" Style="background-color: rgb(250, 255, 189);" />
                        <asp:AutoCompleteExtender ID="aceCustGroup" runat="server" TargetControlID="txtCustGroup" ServiceMethod="GetCustomerGroupNameDesc" ServicePath="~/WebService.asmx"
                            OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" CompletionInterval="10" CompletionSetCount="1" EnableCaching="false"
                            MinimumPrefixLength="1" UseContextKey="true">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblDistributor" runat="server" Text='Distributor' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDistributor" runat="server" Style="background-color: rgb(250, 255, 189);" CssClass="txtDistributor form-control"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender3" runat="server" ServicePath="~/WebService.asmx"
                            ContextKey="2" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating" UseContextKey="true" ServiceMethod="GetDistofPlantState"
                            MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDistributor">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblDealer" runat="server" Text='Dealer' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDealer" runat="server" Style="background-color: rgb(250, 255, 189);" CssClass="txtDealer form-control"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender4" runat="server" ServicePath="~/WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetDealerofDist" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteDealerCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDealer">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblIsActive" runat="server" Text="Is Active" CssClass="input-group-addon"></asp:Label>
                        <asp:CheckBox ID="chkIsActive" runat="server" TabIndex="11" Checked="true" CssClass="form-control" />
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
        <div class="row">
            <div></div>
        </div>
        <div class="row">
            <div class="col-lg-12">
                <asp:GridView runat="server" ID="gvMasterDemoData" Width="100%" Style="font-size: 10px;" AutoGenerateColumns="false" CssClass="table" HeaderStyle-CssClass="table-header-gradient"
                     EmptyDataText="No Record Found.">
                    <columns>
                        <asp:BoundField HeaderText="MasterDemoID" DataField="MasterDemoID" HeaderStyle-Width="3%" />
                        <asp:BoundField HeaderText="Name" DataField="Name" HeaderStyle-Width="6%" />
                        <asp:BoundField HeaderText="RegionName" DataField="RegionName" HeaderStyle-Width="5%" />
                        <asp:BoundField HeaderText="PlantName" DataField="PlantName" HeaderStyle-Width="9%" />
                        <asp:BoundField HeaderText="Active" DataField="Active" HeaderStyle-Width="3%" />
                        <asp:BoundField HeaderText="CustGroupName" DataField="CustGroupName" HeaderStyle-Width="4%" />
                        <asp:BoundField HeaderText="CustGroupDesc" DataField="CustGroupDesc" HeaderStyle-Width="6%" />
                        <asp:BoundField HeaderText="DealerCode" DataField="DealerCode" HeaderStyle-Width="9%" />
                        <asp:BoundField HeaderText="DistributorCode" DataField="DistributorCode" HeaderStyle-Width="9%" />
                        <asp:BoundField HeaderText="CreatedBy" DataField="CreatedBy" HeaderStyle-Width="4%" />
                        <asp:BoundField HeaderText="UpdatedDate" DataField="UpdatedDate" HeaderStyle-Width="5%" DataFormatString="{0:dd/MM/yy HH:mm}" />
                        <asp:BoundField HeaderText="CreatedDate" DataField="CreatedDate" HeaderStyle-Width="5%" DataFormatString="{0:dd/MM/yy HH:mm}" />
                        <%--<asp:TemplateField>
                            <ItemTemplate>
                                <asp:LinkButton runat="server" ID="lbEdit" OnClick="EditDeleteOnclick" Text="Edit" data-ID='<%# Eval("MasterDemoID") %>' data-myData='<%# "Edit" %>'></asp:LinkButton>
                            </ItemTemplate>
                            <HeaderStyle Width="3%" />
                        </asp:TemplateField>--%>
                        <asp:TemplateField>
                            <ItemTemplate>
                                <asp:LinkButton runat="server" ID="lbDelete" OnClick="EditDeleteOnclick" Text="Delete" data-ID='<%# Eval("MasterDemoID") %>' data-myData='<%# "Delete" %>'></asp:LinkButton>
                            </ItemTemplate>
                            <HeaderStyle Width="3%" />
                        </asp:TemplateField>
                    </columns>
                </asp:GridView>
            </div>
        </div>
    </div>
</asp:Content>