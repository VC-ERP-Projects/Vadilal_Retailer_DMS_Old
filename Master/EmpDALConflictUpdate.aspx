<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="EmpDALConflictUpdate.aspx.cs" Inherits="Master_EmpDALConflictUpdate" %>

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

        $(function () {
            ReLoad();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            ReLoad();
        }

        function ReLoad() {

            if ($('.gvCustomerData thead tr').length > 0) {
                $('.gvCustomerData').DataTable({
                    bFilter: true,
                    scrollCollapse: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    "sExtends": "collection",
                    scrollY: '60vh',
                    scrollX: true,
                    responsive: true,
                    dom: 'Bfrtip',
                    "bPaginate": false,
                    "order": [[0, "asc"]],
                    buttons: [],
                    "footerCallback": function (row, data, start, end, display) {
                        var api = this.api(), data;

                        // Remove the formatting to get integer data for summation
                        var intVal = function (i) {
                            return typeof i === 'string' ?
                                i.replace(/[\$,]/g, '') * 1 :
                                typeof i === 'number' ?
                                i : 0;
                        };
                    }
                });
            }
        }

        function ChangeData(txt) {
            if ($(txt).is(':checked')) {
                $(txt).closest('tr').find('.IsChange').val("0");
            }
            else {
                $(txt).closest('tr').find('.IsChange').val("1");
            }
        }
        function _btnCheck() {
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');
            return $('._masterForm').data('bootstrapValidator').isValid();
        }
    </script>
    <style type="text/css">
        table.dataTable tbody tr.odd-row {
            background-color: #e3e7ff;
        }

        table.dataTable tbody tr.even-row {
            background-color: #fff;
        }

        .gvCommon.nowrap.table.dataTable {
            margin: 0;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <asp:HiddenField runat="server" ID="hdnIPAdd" ClientIDMode="Static" Value="0" />
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4 divDealer" id="divDealer" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lbldealer" runat="server" Text="Dealer" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDealerCode" runat="server" TabIndex="10" CssClass="txtDealerCode form-control" autocomplete="off" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtDealerCode" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDealerFromCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDealerCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Generate" TabIndex="14" CssClass="btn btn-default" OnClientClick="return _btnCheck();" OnClick="btnGenerat_Click" />
                        &nbsp
                        <asp:Button Text="Submit" ID="btnSumbit" TabIndex="6" CssClass="btn btn-default" runat="server" OnClick="btnSumbit_Click" />
                    </div>
                </div>
            </div>
            <asp:GridView ID="gvCustomerData" runat="server" CssClass="gvCustomerData table" Width="100%" Style="font-size: 11px;" OnPreRender="gvCustomerData_PreRender"
                ShowFooter="false" AutoGenerateColumns="false" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass="table-header-gradient" EmptyDataText="No data found. ">
                <Columns>
                    <asp:TemplateField HeaderText="No." HeaderStyle-Width="10px" ItemStyle-Width="10px">
                        <ItemTemplate>
                            <%# Container.DataItemIndex + 1 %>
                        </ItemTemplate>
                        <HeaderStyle HorizontalAlign="Center" />
                        <ItemStyle HorizontalAlign="Center" />
                    </asp:TemplateField>
                    <asp:BoundField HeaderText="Dealer Code & Name" HeaderStyle-Width="230px" ItemStyle-Width="230px" DataField="CustomerName" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" />
                    <asp:BoundField HeaderText="Asset Sr. No" HeaderStyle-Width="55px" ItemStyle-Width="55px" DataField="SerialNumber" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" />
                    <asp:BoundField HeaderText="Conflict Date" HeaderStyle-Width="40px" ItemStyle-Width="40px" DataField="ConflictDate" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                    <asp:TemplateField HeaderText="Conflict" HeaderStyle-Width="20px" ItemStyle-Width="20px">
                        <ItemTemplate>
                            <input type="checkbox" name="chkCheck" class="chkCheck" id="chkcheck" runat="server" onchange="ChangeData(this);" checked='<%# Convert.ToBoolean(Eval("IsConflict")) %>' value='<%# Eval("IsConflict") %>' />
                            <input type="hidden" id="hdnOASTCMID" runat="server" value='<%# Eval("OASTCMID") %>' />
                            <input type="hidden" runat="server" id="IsChange" value="0" name="IsChange" class="IsChange" />
                        </ItemTemplate>
                        <HeaderStyle HorizontalAlign="Center" />
                        <ItemStyle HorizontalAlign="Center" />
                    </asp:TemplateField>
                    <asp:BoundField HeaderText="Created Date/Time" HeaderStyle-Width="40px" ItemStyle-Width="40px" DataField="CreatedDate" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                    <asp:BoundField HeaderText="Created By" HeaderStyle-Width="70px" ItemStyle-Width="70px" DataField="CreatedBy" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" />
                    <asp:BoundField HeaderText="Updated Date/Time" HeaderStyle-Width="40px" ItemStyle-Width="40px" DataField="UpdatedDate" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                    <asp:BoundField HeaderText="Updated By" HeaderStyle-Width="70px" ItemStyle-Width="70px" DataField="UpdatedBy" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" />
                </Columns>
            </asp:GridView>
        </div>
    </div>
</asp:Content>

