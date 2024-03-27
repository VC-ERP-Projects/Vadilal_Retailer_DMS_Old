<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="BeatDisplayUtility.aspx.cs" Inherits="Reports_BeatDisplayUtility" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../Scripts/datatable_new/jquery.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/datatable_new/buttons.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/colorbox/colorbox.css" rel="stylesheet" />

    <script src="../Scripts/datatable_new/jquery.dataTables.min.js"></script>
    <script src="../Scripts/datatable_new/dataTables.buttons.min.js"></script>
    <script src="../Scripts/datatable_new/buttons.html5.min.js"></script>
    <script src="../Scripts/datatable_new/pdfmake.min.js"></script>
    <script src="../Scripts/datatable_new/vfs_fonts.js"></script>
    <script src="../Scripts/datatable_new/jszip.min.js"></script>
    <script type="text/javascript" src="../Scripts/colorbox/jquery.colorbox-min.js"></script>

    <script type="text/javascript">

        $(function () {
            Reload();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            Reload();
        }

        function EmpHrchyPopUp(lnk) {
            var EmpID = Number($(lnk).attr('empid'));
            $.ajax({
                url: 'BeatDisplayUtility.aspx/GetEmpHierarchy',
                type: 'POST',
                dataType: 'json',
                data: JSON.stringify({ EmpID: EmpID }),
                contentType: 'application/json',
                success: function (result) {

                    if (result == "") {
                        alert('No Data Found.');
                        event.preventDefault();
                        return false;
                    }
                    else {
                        var str = "";
                        result.d = result.d.reverse();
                        str = "<table border='1' width='100%' class='table'>";
                        str += "<tr class='table-header-gradient'><td style='width:60px;'>Sr No.</td><td>Emp Code # Name</td></tr>";
                        for (var i = 0; i < result.d.length; i++) {
                            str += "<tr><td>" + (i + 1).toString() + "</td><td>" + result.d[i] + "</td></tr>";
                        }
                        str += "</table><br/>";

                        $.colorbox({
                            width: '50%',
                            height: '405px',
                            iframe: false,
                            html: str
                        });
                    }
                }
            });
        }

        function Reload() {

            if ($('.gvdata thead tr').length > 0) {

                var table = $(".gvdata").DataTable();
                var colCount = table.columns()[0].length;

                var aryJSONColTable = [];

                aryJSONColTable.push({ "width": "3px", "aTargets": 0 });
                aryJSONColTable.push({ "width": "90px", "aTargets": 1 });
                aryJSONColTable.push({ "width": "3px", "aTargets": 2 });
                aryJSONColTable.push({ "width": "3px", "aTargets": 3 });
                aryJSONColTable.push({ "width": "6px", "aTargets": 4 });
                aryJSONColTable.push({ "width": "90px", "aTargets": 5 });
                aryJSONColTable.push({ "width": "10px", "aTargets": 6 });
                aryJSONColTable.push({ "width": "50px", "aTargets": 7 });

                $('.gvdata').DataTable(
                   {
                       bFilter: true,
                       scrollCollapse: true,
                       "stripeClasses": ['odd-row', 'even-row'],
                       destroy: true,
                       scrollY: '50vh',
                       "order": [],
                       scrollX: true,
                       responsive: true,
                       "bPaginate": false,
                       "aoColumnDefs": aryJSONColTable
                   });
            }
        }

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

        .dtbodyCenter {
            text-align: center;
        }

        div.dataTables_wrapper {
            margin: 0 auto;
        }

    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-6">
                    <div class="input-group form-group" runat="server">
                        <asp:Label ID="lblCustomer" runat="server" Text="Customer" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCustCode" runat="server" TabIndex="1" CssClass="txtCustCode form-control" autocomplete="off" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetCustomerByTypePlantState" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCustCode" ContextKey="0-0-0-2,3,4">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="input-group form-group" runat="server">
                        <asp:Label ID="lblParent" runat="server" Text="Parent" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtParent" runat="server" TabIndex="2" CssClass="txtParent form-control" Enabled="false"></asp:TextBox>
                    </div>
                </div>
            </div>
            <div class="input-group form-group">
                <asp:Button ID="btnGenerat" runat="server" Text="Display" CssClass="btn btn-default" OnClick="btnGenerat_Click" TabIndex="8" />&nbsp
            </div>
            <div class="row">
                <div class="col-lg-12">
                    <asp:GridView ID="gvdata" runat="server" CssClass="gvdata table tbl" Font-Size="11px" Width="100%"
                        OnPreRender="gvdata_PreRender" EmptyDataText="No data found." AutoGenerateColumns="false" HeaderStyle-CssClass="table-header-gradient">
                        <Columns>
                            <asp:BoundField HeaderText="Beat Code" DataField="BeatCode" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" />
                            <asp:BoundField HeaderText="Beat Name" DataField="BeatName" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" />
                            <asp:BoundField HeaderText="Beat Type" DataField="BeatType" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" />
                            <asp:BoundField HeaderText="Beat Status" DataField="BeatStatus" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" />
                            <asp:BoundField HeaderText="Customer Status" DataField="CustomerStatus" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" />
                            <asp:BoundField HeaderText="Last Updated By & Date/Time" DataField="LastUpdatedByDateTime" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" FooterStyle-HorizontalAlign="Left" />
                            <asp:TemplateField HeaderText="Emp Code" FooterStyle-HorizontalAlign="Left">
                                <ItemTemplate>
                                    <asp:LinkButton ID="lblEmpID" runat="server" empid='<%# Eval("EmpID") %>' OnClientClick="EmpHrchyPopUp(this); return false;" CssClass="lblEmpID" Style="text-align: Left;" Text='<%# Bind("EmpCode") %>'></asp:LinkButton>
                                </ItemTemplate>
                                <ItemStyle HorizontalAlign="Left" />
                                <HeaderStyle HorizontalAlign="Left" />
                            </asp:TemplateField>
                            <asp:BoundField HeaderText="Emp Name" DataField="EmpName" ItemStyle-HorizontalAlign="Left" HeaderStyle-HorizontalAlign="Left" FooterStyle-HorizontalAlign="Left" />
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

