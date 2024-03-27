<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" CodeFile="AssetRegisterRpt.aspx.cs" Inherits="Reports_AssetRegisterRpt" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">
        function autoCompletePlant_OnClientPopulating(sender, args) {
            var StateId = $('.txtPlantRegion').is(":visible") ? $('.txtPlantRegion').val().split('-').pop() : "0";
            var PlantId = $('.txtPlant').is(":visible") ? $('.txtPlant').val().split('-').pop() : "0";
            sender.set_contextKey(StateId + "-0-" + PlantId+ "-0-2,3,4");
        }
        function ddlLyingChange() {
            var ddlval = $('.ddlLying').val();
            if (ddlval == '9') {
                $('.txtEmployee').val('');
                $('.txtCustomerRegion').val('');
                $('.txtParentRegion').val('');
                $('.txtCustomer').val('');
                $('.txtParentCode').val('');
                $('.dvNostorageloc').css('display', 'none');
                $('.dvStoragelocation').css('display', 'block');
            }
            else {
                $('.dvNostorageloc').css('display', 'block');
                $('.txtStorageLocation').val('');
                $('.txtPlant').val('');
                $('.txtPlantRegion').val('');
                $('.dvStoragelocation').css('display', 'none');
            }
        }
        function ddlParentOptionChange() {
            var ddlparent = $('.ddlParent').val();
            if (ddlparent == '1') {
                $('.dvWithParent').css('display', 'block');
            }
            else {
                $('.txtEmployee').val('');
                $('.txtCustomerRegion').val('');
                $('.txtParentRegion').val('');
                $('.txtCustomer').val('');
                $('.txtParentCode').val('');
                $('.dvWithParent').css('display', 'none');
            }
        }
        $(document).ready(function () {
            ddlLyingChange();
            ddlParentOptionChange();
        });
    </script>
    <style type="text/css">
        table.dataTable tbody tr.odd-row {
            background-color: #e3e7ff;
        }

        table.dataTable tbody tr.even-row {
            background-color: #fff;
        }

        .dataTables_scroll {
            overflow: auto;
        }

        .dtbodyRight {
            text-align: right;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row">
                <div class="col-lg-12">
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Label runat="server" ID="lblLying" Text="Lying At" CssClass="input-group-addon"></asp:Label>
                            <asp:DropDownList runat="server" ID="ddlLying" CssClass="ddlLying form-control" onchange="ddlLyingChange()" TabIndex="1">
                                <asp:ListItem Text="Dealer" Value="3" Selected="True" />
                                <asp:ListItem Text="Distributor" Value="2" />
                                <asp:ListItem Text="Super Stockist" Value="4" />
                                <asp:ListItem Text="Dealer + Dist + SS" Value="0" />
                                <asp:ListItem Text="Storage Location" Value="9" />
                            </asp:DropDownList>
                        </div>
                        <div class="input-group form-group">
                            <asp:Label ID="lblAcqFromDate" runat="server" Text="Acquisition From" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtAcqFromDate" TabIndex="4" runat="server" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="fromdate form-control"></asp:TextBox>
                        </div>
                        <div class="input-group form-group">
                            <asp:Label ID="lblLgmFromdate" runat="server" Text="LGM From" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtLgmFromDate" TabIndex="7" runat="server" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="fromdate form-control"></asp:TextBox>
                        </div>
                        <div class="input-group form-group">
                            <asp:Label ID="lblSyncFrom" runat="server" Text="Last Sync From" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtSyncFrom" TabIndex="10" runat="server" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="fromdate form-control"></asp:TextBox>
                        </div>
                        <div class="input-group form-group">
                            <asp:Label ID="lblServiceFrom" runat="server" Text="Last Service From" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtServiceFrom" TabIndex="13" runat="server" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="fromdate form-control"></asp:TextBox>
                        </div>
                        <div class="input-group form-group">
                            <asp:Label ID="lblRSDEmployee" runat="server" Text="RSD Employee" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtRSDEmployee" runat="server" TabIndex="16" CssClass="txtRSDEmployee form-control" Style="background-color: rgb(250, 255, 189);" autocomplete="off"></asp:TextBox>
                            <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender1" runat="server" ServicePath="../Service.asmx"
                                UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                                EnableCaching="false" CompletionSetCount="1" TargetControlID="txtRSDEmployee">
                            </asp:AutoCompleteExtender>
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Label ID="lblreasoncode" Text="Asset Type" runat="server" CssClass="input-group-addon" />
                            <asp:DropDownList ID="ddlAssetType" runat="server" TabIndex="2" CssClass="ddlAssetType form-control"></asp:DropDownList>
                        </div>
                        <div class="input-group form-group">
                            <asp:Label ID="lblAcqToDate" runat="server" Text="Acquisition To" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtAcqToDate" TabIndex="5" runat="server" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="todate form-control"></asp:TextBox>
                        </div>
                        <div class="input-group form-group">
                            <asp:Label ID="lblLgmTodate" runat="server" Text="LGM To" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtLgmTodate" TabIndex="8" runat="server" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="todate form-control"></asp:TextBox>
                        </div>
                        <div class="input-group form-group">
                            <asp:Label ID="lblSyncTo" runat="server" Text="Last Sync To" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtSyncTo" TabIndex="11" runat="server" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="todate form-control"></asp:TextBox>
                        </div>
                        <div class="input-group form-group">
                            <asp:Label ID="lblServiceTo" runat="server" Text="Last Service To" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtServiceTo" TabIndex="14" runat="server" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="todate form-control"></asp:TextBox>
                        </div>
                        <div class="input-group form-group">
                            <asp:Label ID="lblMechanic" runat="server" Text="RSD Mechanic" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtRSDMechanic" TabIndex="17" runat="server" MaxLength="10" CssClass="txtRSDMechanic form-control" Style="background-color: rgb(250, 255, 189);" autocomplete="off"></asp:TextBox>
                            <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender3" runat="server" ServicePath="../Service.asmx"
                                UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                                EnableCaching="false" CompletionSetCount="1" TargetControlID="txtRSDMechanic">
                            </asp:AutoCompleteExtender>
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Label ID="Label2" runat="server" Text="Asset Model" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtAssetModel" runat="server" TabIndex="3" Style="background-color: rgb(250, 255, 189);" CssClass="txtAssetModel form-control" autocomplete="off"></asp:TextBox>
                            <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtAssetModel" runat="server" ServicePath="../WebService.asmx"
                                UseContextKey="false" ServiceMethod="GetAssetModel" MinimumPrefixLength="1" CompletionInterval="10"
                                EnableCaching="false" CompletionSetCount="1" TargetControlID="txtAssetModel">
                            </asp:AutoCompleteExtender>
                        </div>
                        <div class="input-group form-group">
                            <asp:Label ID="lblSerialNo" runat="server" Text="Asset Serial No" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtSerialNo" TabIndex="6" runat="server" MaxLength="10" CssClass="txtSerialNo form-control" Style="background-color: rgb(250, 255, 189);" autocomplete="off"></asp:TextBox>
                            <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender4" runat="server" ServicePath="../Service.asmx"
                                UseContextKey="true" ServiceMethod="GetAssetSerialNo" MinimumPrefixLength="1" CompletionInterval="10"
                                EnableCaching="false" CompletionSetCount="1" TargetControlID="txtSerialNo">
                            </asp:AutoCompleteExtender>
                        </div>
                        <div class="input-group form-group">
                            <asp:Label ID="lblRSDLocation" runat="server" Text="RSD Location" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtRSDLocation" TabIndex="9" runat="server" MaxLength="10" CssClass="txtRSDLocation form-control" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                            <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender5" runat="server" ServicePath="../WebService.asmx"
                                UseContextKey="true" ServiceMethod="GetStorageLocation" MinimumPrefixLength="1" CompletionInterval="10"
                                EnableCaching="false" CompletionSetCount="12" TargetControlID="txtRSDLocation">
                            </asp:AutoCompleteExtender>
                        </div>
                        <div class="input-group form-group">
                            <asp:Label ID="Label3" runat="server" Text="Asset Code" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtAssetCode" runat="server" TabIndex="12" Style="background-color: rgb(250, 255, 189);" CssClass="txtAssetCode form-control"></asp:TextBox>
                            <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtAssetCode" runat="server" ServicePath="../WebService.asmx"
                                UseContextKey="true" ServiceMethod="GetAssetsCode" MinimumPrefixLength="1" CompletionInterval="10"
                                EnableCaching="false" CompletionSetCount="12" TargetControlID="txtAssetCode">
                            </asp:AutoCompleteExtender>
                        </div>
                        <div class="input-group form-group">
                            <asp:Label ID="lblSize" runat="server" Text="Asset Size (CFT)" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtSize" TabIndex="15" runat="server" MaxLength="10" CssClass="txtSize form-control"></asp:TextBox>
                        </div>
                    </div>
                </div>
                <div class="dvNostorageloc" runat="server" id="dvNostorageloc">
                    <div class="col-lg-12">
                        <div class="col-lg-4">
                            <div class="input-group form-group ">
                                <asp:Label runat="server" ID="lblParentOption" Text="Parent Option" CssClass="input-group-addon"></asp:Label>
                                <asp:DropDownList TabIndex="18" runat="server" ID="ddlParent" CssClass="ddlParent form-control" onchange="ddlParentOptionChange()" >
                                    <asp:ListItem Text="With Parent" Value="1" Selected="True" />
                                    <asp:ListItem Text="No Parent" Value="0" />
                                </asp:DropDownList>
                            </div>
                        </div>
                    </div>
                    <%--With Parent--%>
                    <div class="dvWithParent col-lg-12" id="dvWithParent" runat="server">
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label ID="lblEmployee" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtEmployee" runat="server" TabIndex="19" Style="background-color: rgb(250, 255, 189);" CssClass="txtEmployee form-control" autocomplete="off"></asp:TextBox>
                                <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender2" runat="server" ServicePath="../Service.asmx"
                                    UseContextKey="true" ServiceMethod="GetEmployeeListTillM4" MinimumPrefixLength="1" CompletionInterval="10"
                                    EnableCaching="false" CompletionSetCount="1" TargetControlID="txtEmployee">
                                </asp:AutoCompleteExtender>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblCustomerRegion" runat="server" Text="Region of Customer" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtCustomerRegion" TabIndex="22" runat="server" MaxLength="10" CssClass="txtCustomerRegion form-control" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                                <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender7" runat="server"
                                    ServiceMethod="GetStates" ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1"
                                    TargetControlID="txtCustomerRegion" UseContextKey="True">
                                </asp:AutoCompleteExtender>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblSalesFrom" runat="server" Text="Sales From Date" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtSalesFrom" TabIndex="25" runat="server" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="fromdate form-control"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label ID="lblParentRegion" runat="server" Text="Region of Parent" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtParentRegion" TabIndex="20" runat="server" MaxLength="10" CssClass="txtParentRegion form-control" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                                <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender6" runat="server"
                                    ServiceMethod="GetStates" ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1"
                                    TargetControlID="txtParentRegion" UseContextKey="True">
                                </asp:AutoCompleteExtender>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblCustomer" runat="server" Text="Customer" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtCustomer" TabIndex="23" runat="server" MaxLength="10" CssClass="txtCustomer form-control" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                                <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender8" runat="server"
                                    ServiceMethod="GetCustomerWithoutType" ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1"
                                    TargetControlID="txtCustomer" UseContextKey="True">
                                </asp:AutoCompleteExtender>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label ID="lblSalesTo" runat="server" Text="Sales Date To" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtSalesTo" TabIndex="26" runat="server" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="todate form-control"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-lg-4">
                            <div class="input-group form-group">
                                <asp:Label ID="lblParentCode" runat="server" Text="Parent Code" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtParentCode" TabIndex="21" runat="server" MaxLength="10" CssClass="txtParentCode form-control" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                                <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender9" runat="server"
                                    ServiceMethod="GetCustomerWithoutType" ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1"
                                    TargetControlID="txtParentCode" UseContextKey="True">
                                </asp:AutoCompleteExtender>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label runat="server" ID="lblSales" Text="Sales/Deposit" CssClass="input-group-addon"></asp:Label>
                                <asp:DropDownList runat="server" ID="ddlSales" CssClass="ddlSales form-control" TabIndex="24">
                                    <asp:ListItem Text="Deposit" Value="1" Selected="True" />
                                    <asp:ListItem Text="Sales" Value="99999" />
                                </asp:DropDownList>
                            </div>

                        </div>
                    </div>
                </div>
                <div class="dvStoragelocation col-lg-12" runat="server" id="dvStoragelocation">
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Label ID="lblPlantRegion" runat="server" Text="Plant Region" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtPlantRegion" TabIndex="19" runat="server" MaxLength="10" CssClass="txtPlantRegion form-control" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                            <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender10" runat="server"
                                ServiceMethod="GetStates" ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1"
                                TargetControlID="txtPlantRegion" UseContextKey="True">
                            </asp:AutoCompleteExtender>
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Label ID="lblPlant" runat="server" Text="Plant" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtPlant" TabIndex="20" runat="server" MaxLength="10" CssClass="txtPlant form-control" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                            <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender11" runat="server" 
                                ServiceMethod="GetPlants" ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1"
                                TargetControlID="txtPlant" UseContextKey="True">
                            </asp:AutoCompleteExtender>  <%--OnClientPopulating="autoCompletePlant_OnClientPopulating"--%>
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Label ID="lblStorageLocation" runat="server" Text="Storage Location" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtStorageLocation" TabIndex="21" runat="server" MaxLength="10" CssClass="txtStorageLocation form-control" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                            <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender12" runat="server"
                                ServiceMethod="GetStorageLocation" ServicePath="../WebService.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1"
                                TargetControlID="txtStorageLocation" UseContextKey="True">
                            </asp:AutoCompleteExtender>
                        </div>
                    </div>
                </div>
                <div class="col-lg-12">
                    <div class="col-lg-4">
                        <asp:Button ID="btnGo" runat="server" Text="Go" TabIndex="27" CssClass="btn btn-default" OnClick="btnGo_Click" />
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

