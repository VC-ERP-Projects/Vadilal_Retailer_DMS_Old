<%@ Page Title="" Language="C#" MasterPageFile="~/MainMaster.master" AutoEventWireup="true" CodeFile="ViewProfile.aspx.cs" Inherits="MyAccount_ViewProfile" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../Scripts/datatable/jquery.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/datatable/buttons.dataTables.min.css" rel="stylesheet" />

    <script src="../Scripts/datatable/jquery.dataTables.min.js"></script>
    <script src="../Scripts/datatable/dataTables.buttons.min.js"></script>
    <script src="../Scripts/datatable/buttons.flash.min.js"></script>


    <script type="text/javascript" src="https://cdn.datatables.net/v/dt/dt-1.10.15/datatables.min.js"></script>

    <script type="text/javascript">

        $(function () {
            if ($('.gvProfile thead tr').length > 0) {
                $('.gvProfile').DataTable(
                    {
                        bFilter: true,
                        scrollCollapse: true,
                        destroy: true,
                        scrollY: '60vh',
                        scrollX: true,
                        responsive: true,
                        dom: 'Bfrtip',
                        "stripeClasses": ['odd-row', 'even-row'],
                        "bPaginate": false,
                        buttons: [{ extend: 'copy', footer: true },
                            {
                                extend: 'csv', footer: true, filename: 'AttendenceRegister_' + new Date().toLocaleDateString(),
                            },
                            {
                                extend: 'excel', footer: true, filename: 'AttendenceRegister_' + new Date().toLocaleDateString(),
                            },
                            {
                                extend: 'pdf',
                                orientation: 'landscape',
                                title: 'Attendence Register',
                                message: 'Process Month : ' + $('.onlymonth').val(),
                                pageSize: 'LEGAL'
                            }]

                    });
            }
        });


    </script>

    <style type="text/css">
        div.dataTables_wrapper {
            margin: 0 auto;
        }

        .ui-datepicker-calendar {
            display: none;
        }

        table.dataTable tbody tr.odd-row {
            background-color: #e3e7ff;
        }

        table.dataTable tbody tr.even-row {
            background-color: #fff;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel panel-default" style="margin-top: 45px; margin-left: 18px;">
        <div class="panel-body">
            <div class="row">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Status" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList ID="ddlStatus" runat="server" AutoPostBack="True" CssClass="form-control" OnSelectedIndexChanged="ddlStatus_SelectedIndexChanged">
                            <asp:ListItem Text="---- All ----" Value="0" />
                            <asp:ListItem Text="Not Varified" Value="1" Selected="True" />
                            <asp:ListItem Text="Varified" Value="2" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblIsComposite" runat="server" Text="In Composite Scheme" CssClass="input-group-addon"></asp:Label>
                        <asp:CheckBox ID="chkIsComposite" runat="server" OnCheckedChanged="ddlStatus_SelectedIndexChanged" AutoPostBack="true" CssClass="form-control" />
                    </div>
                </div>
            </div>
            <div class="col-lg-12">
                <asp:GridView runat="server" ID="gvProfile" Font-Size="11px" CssClass="gvProfile nowrap table" AutoGenerateColumns="false" OnPreRender="gvProfile_PreRender" OnRowCommand="gvProfile_RowCommand" HeaderStyle-CssClass="table-header-gradient" EmptyDataText="No Item Found.">
                    <Columns>
                        <asp:TemplateField HeaderText="No." HeaderStyle-Width="3%">
                            <ItemTemplate>
                                <asp:Label ID="lblNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField HeaderText="Distributor Code" DataField="CustomerCode" HeaderStyle-Width="10%" />
                        <asp:BoundField HeaderText="Distributor Name" DataField="CustomerName" HeaderStyle-Width="25%" />
                        <asp:BoundField HeaderText="Status" DataField="Status" HeaderStyle-Width="8%" />
                        <asp:BoundField HeaderText="Created Date" DataField="CreatedDate" DataFormatString="{0:dd/MM/yyyy hh:mm:ss}" HeaderStyle-Width="12%" />
                        <asp:BoundField HeaderText="Varify Date" DataField="VerifyDate" DataFormatString="{0:dd/MM/yyyy hh:mm:ss}" HeaderStyle-Width="12%" />
                        <asp:BoundField HeaderText="Varify By" DataField="VerifyBy" HeaderStyle-Width="8%" />
                        <asp:BoundField HeaderText="GST No" DataField="GST" HeaderStyle-Width="12%" />
                        <asp:BoundField HeaderText="PAN No" DataField="PAN" HeaderStyle-Width="12%" />
                        <asp:TemplateField HeaderText="Active" HeaderStyle-Width="12%">
                            <ItemTemplate>
                                <a href='<%# string.Format("../MyAccount/MyProfile.aspx?DocNo={0}&DocKey={1}",Eval("TcustID"),Eval("ParentID"))%>' target="_blank">View & Update</a>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Delete" HeaderStyle-Width="4%">
                            <ItemTemplate>
                                <asp:LinkButton ID="lnkDelete" Text="Delete" runat="server" CommandName="DeleteMode " CommandArgument='<%# Eval("TcustID") + "," + Eval("ParentID") %>' alt="Delete" OnClientClick="return confirm('Are you sure to delete thease entry ?');"></asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>

        </div>
    </div>
</asp:Content>



