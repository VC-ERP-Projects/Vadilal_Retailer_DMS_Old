<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="BDMTask.aspx.cs" Inherits="Reports_BDMTask" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../Scripts/datatable_new/jquery.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/datatable_new/buttons.dataTables.min.css" rel="stylesheet" />

    <script src="../Scripts/datatable_new/jquery.dataTables.min.js"></script>
    <script src="../Scripts/datatable_new/dataTables.buttons.min.js"></script>
    <script src="../Scripts/datatable_new/buttons.html5.min.js"></script>
    <script src="../Scripts/datatable_new/pdfmake.min.js"></script>
    <script src="../Scripts/datatable_new/vfs_fonts.js"></script>
    <script src="../Scripts/datatable_new/jszip.min.js"></script>
    <script type="text/javascript">

        function acetxtDealerCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            var City = $('.txtCity').is(":visible") ? $('.txtCity').val().split('-').pop() : "0";
            sender.set_contextKey("0-" + City + "-0" + "-" + "0" + "-" + "0" + "-" + EmpID);
        }

        function acettxtCity_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey("0" + "-" + EmpID);
        }

        function acettxtSerialNo_OnClientPopulating(sender, args) {
            var MachineTypeID = $('.ddlMachineType').is(":visible") ? $('.ddlMachineType').val() : "0";

            sender.set_contextKey(MachineTypeID);
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group divfromdate">
                        <asp:Label ID="lblFromDate" runat="server" Text="From Date" CssClass="lblFromDate input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromDate" runat="server" MaxLength="10" TabIndex="1" onkeyup="return ValidateDate(this);" CssClass="fromdate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group divtodate">
                        <asp:Label ID="lblToDate" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtToDate" runat="server" TabIndex="2" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="todate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4" id="divEmpCode" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Employee/Mechanic" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" runat="server" CssClass="form-control txtCode" Style="background-color: rgb(250, 255, 189);" TabIndex="3"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4" id="div1" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="Label1" runat="server" Text="RSD Location" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtlocation" runat="server" CssClass="form-control txtlocation" Style="background-color: rgb(250, 255, 189);" TabIndex="4"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" runat="server" ServicePath="../WebService.asmx"
                            UseContextKey="true" MinimumPrefixLength="1" CompletionInterval="10" ServiceMethod="GetStorageLocation"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtlocation">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4" style="display: none">
                    <div class="input-group form-group">
                        <asp:Label Text="Dealer City" ID="lblCity" runat="server" CssClass="lblCity input-group-addon" autocomplete="off" />
                        <asp:TextBox runat="server" ID="txtCity" CssClass="txtCity form-control" Style="background-color: rgb(250, 255, 189);" autocomplete="off" TabIndex="5" />
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtCity" runat="server"
                            ServicePath="../Service.asmx" UseContextKey="true" MinimumPrefixLength="1" ServiceMethod="GetCitysCurrHierarchy" OnClientPopulating="acettxtCity_OnClientPopulating"
                            CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCity">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lbldealer" runat="server" Text="Customer" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDealerCode" runat="server" TabIndex="6" Style="background-color: rgb(250, 255, 189);" CssClass="txtDealerCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtDealerCode" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" MinimumPrefixLength="1" CompletionInterval="10" ServiceMethod="GetCustomerByAllTypeWithoutTemp" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDealerCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4" id="div2" runat="server" style="display: none">
                    <div class="input-group form-group">
                        <asp:Label ID="lblMechEmp" runat="server" Text="Mechanic Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtMechEmp" runat="server" CssClass="form-control txtMechEmp" Style="background-color: rgb(250, 255, 189);" TabIndex="7"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender1" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtMechEmp">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Machine Type" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList runat="server" ID="ddlMachineType" TabIndex="8" CssClass="ddlMachineType form-control" DataTextField="MachineTypeName" DataValueField="MachineTypeID">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblSerialNumber" runat="server" Text='Asset Serial Number' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtAssetSerialNo" Style="background-color: rgb(250, 255, 189);" CssClass="txtAssetSerialNo form-control" runat="server" TabIndex="9"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtAssetSerialNo" runat="server" ServicePath="../Service.asmx" OnClientPopulating="acettxtSerialNo_OnClientPopulating"
                            UseContextKey="true" ServiceMethod="GetTypeWiseAssetSerialNo" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtAssetSerialNo">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="BreakDown Type" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList runat="server" ID="ddlBDMType" TabIndex="10" CssClass="ddlBDMType form-control" DataTextField="ProblemName" DataValueField="ProblemID">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Export-Data" TabIndex="11" CssClass="btnGenerat btn btn-default" OnClick="btnGenerat_Click" />
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

