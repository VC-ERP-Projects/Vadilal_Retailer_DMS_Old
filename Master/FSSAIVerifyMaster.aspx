<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="FSSAIVerifyMaster.aspx.cs" Inherits="Master_FSSAIVerifyMaster" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../Scripts/datatable_new/jquery.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/datatable_new/buttons.dataTables.min.css" rel="stylesheet" />

    <script src="../Scripts/datatable_new/jquery.dataTables.min.js"></script>
    <script src="../Scripts/datatable_new/dataTables.buttons.min.js"></script>
    <script src="../Scripts/datatable_new/buttons.html5.min.js"></script>
    <script src="../Scripts/datatable_new/pdfmake.min.js"></script>
    <script src="../Scripts/datatable_new/vfs_fonts.js"></script>
    <script src="../Scripts/datatable_new/jszip.min.js"></script>

    <link href="../Scripts/colorbox/colorbox.css" rel="stylesheet" />
    <script type="text/javascript" src="../Scripts/colorbox/jquery.colorbox-min.js"></script>
    <script type="text/javascript" src="../Scripts/fixHeaderFooter.js"></script>
    <script type="text/javascript">

        var CustType = <% = CustType%>;
        var ParentID = <% = ParentID%>;

        $(function () {
            ReLoadFn();

            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
            //$('.gvOrder').tableHeadFixer('65vh');
            //$('.divCustEntry').tableHeadFixer('65vh');
            $(".gvOrder").tableHeadFixer('52vh');
        });

        function EndRequestHandler2(sender, args) {
            ReLoadFn();
        }



        function ReloadRadio() {
            if ($('.chkCheck').length == $('.chkCheck:checked').length)
                $('.chkhead').prop('checked', true);
            else
                $('.chkhead').prop('checked', false);
        }
        $(document).ready(function () {
          //  $('.gvOrder').DataTable();       //capital "D"
        });
        function ReLoadFn() {
            var table = $('.gvOrder').DataTable();
            var aryJSONColTable = [];

            aryJSONColTable.push({ "bSortable": "false", "width": "20px", "sClass": "dtbodyCenter", "aTargets": 0 });
            aryJSONColTable.push({ "bSortable": "false", "width": "20px", "sClass": "dtbodyCenter", "aTargets": 1 });
            aryJSONColTable.push({ "bSortable": "false", "width": "30px", "aTargets": 2 });
            aryJSONColTable.push({ "bSortable": "false", "width": "90px", "aTargets": 3 });
            aryJSONColTable.push({ "bSortable": "false", "width": "50px", "aTargets": 4 });
            aryJSONColTable.push({ "bSortable": "false", "width": "35px", "aTargets": 5 });
            aryJSONColTable.push({ "bSortable": "false", "width": "40px", "aTargets": 6 });//"sClass": "dtbodyLeft",
            aryJSONColTable.push({ "bSortable": "false", "width": "30px", "sClass": "dtbodyRight", "aTargets": 7 });
            aryJSONColTable.push({ "bSortable": "false", "width": "35px", "sClass": "dtbodyCenter", "aTargets": 8 });
            aryJSONColTable.push({ "bSortable": "false", "width": "35px", "sClass": "dtbodyCenter", "aTargets": 9 });

            $('.gvOrder').DataTable({
                bFilter: false,
                scrollCollapse: false,
                "sExtends": "collection",
                scrollX: true,
                scrollY: '53vh',
                responsive: true,
                "bPaginate": false,
                ordering: false,
                "bInfo": true,
                "autoWidth": false,
                destroy: true,
                "aoColumnDefs": aryJSONColTable,
                "ordering": false,
                "bSort": false,
            });
            //$('.dataTables_scrollFoot').css('overflow', 'auto');
            //$($.fn.dataTable.tables(true)).DataTable().columns.adjust();
            $(".txtgvItemSearch").keyup(function () {
                var word = this.value;
                $(".gvOrder > tbody tr").not(':first').each(function () {
                    if ($(this).find("td").text().toUpperCase().indexOf(word.toUpperCase()) >= 0)
                        $(this).show();
                    else
                        $(this).hide();

                });
            });
        }

        function ClickHead(chk) {
            if ($(chk).is(':checked')) {
                $('.chkCheck').prop('checked', true);
            }
            else {
                $('.chkCheck').prop('checked', false);
            }
        }

        function _btnCheck() {
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            IsValid = $('._masterForm').data('bootstrapValidator').isValid();
        }
    </script>
    <style>
        #page-content-wrapper {
            overflow: hidden;
        }

        .dataTables_scrollHeadInner {
            width: auto;
        }

        .dataTables_scrollBody {
            overflow-x: hidden !important;
            min-height:0px !important;
        }

        .dataTables_scroll {
            overflow: auto;
        }

        table.dataTable thead th.dtbodySrNo {
            padding: 5px 10px !important;
        }

        .dtbodyRight {
            text-align: right !important;
        }

        .dtbodyCenter {
            text-align: center !important;
        }

        div.dataTables_wrapper {
            margin: 0 auto;
        }
         .table > thead > tr > th {
           padding: 3px !important;
            vertical-align: middle !important;
        }
         .table > tbody > tr > th, .table > tfoot > tr > th, .table > thead > tr > td, .table > tbody > tr > td, .table > tfoot > tr > td {
            /*padding-left: 4px !important;*/
            padding: 0px !important;
            vertical-align: middle !important;
            /*white-space: nowrap;*/
            /*overflow-x: scroll;*/
        }

        @media (min-width: 1200px) {
            #body_gvOrder_wrapper .dataTables_scrollHead {
                width: 950px !important;
            }

            #body_gvOrder_wrapper .dataTables_scrollBody {
                width: 950px !important;
            }

            #body_gvOrder_wrapper .dataTables_scrollFoot {
                width: 950px !important;
            }

            #body_gvOrder_wrapper .dataTables_scrollFootInner {
                width: 950px !important;
            }

            .tdleftalign {
                margin-left: 3px !important;
                margin-right: 7px !important;
            }

            .tdrightalign {
                margin-right: 4px !important;
            }

            .CustName {
                /*overflow: auto;*/
                white-space: nowrap;
                overflow-x: scroll;
                margin-left: 3px !important;
            }

                .CustName::-webkit-scrollbar {
                    display: none;
                }
            /*table > thead > tr > th, .table > tbody > tr > th, .table > tfoot > tr > th, .table > thead > tr > td, .table > tbody > tr > td, .table > tfoot > tr > td::-webkit-scrollbar {
                display: none;
            }*/

            /* Hide scrollbar for IE, Edge and Firefox */
            .CustName {
                -ms-overflow-style: none; /* IE and Edge */
                scrollbar-width: none; /* Firefox */
            }

         
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body _masterForm">
            <div class="row" style="display: none;">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromDate" runat="server" Text="Last Proceed From" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromDate" runat="server" TabIndex="1" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="fromdate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate" runat="server" Text="Last Proceed To" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtToDate" runat="server" TabIndex="2" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="todate form-control"></asp:TextBox>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-8">
                    <asp:Button ID="btnSearch" runat="server" Text="Verify" TabIndex="10" CssClass="btn btn-success" OnClientClick="return _btnCheck();" OnClick="btnSearch_Click" />
                    <asp:Button ID="btnGenerat" runat="server" Text="Reject" TabIndex="11" CssClass="btn btn-danger" OnClick="btnGenerat_Click" />
                </div>
                <div class="col-lg-4">
                    <asp:TextBox runat="server" placeholder="Search here" ID="txtgvItemSearch" TabIndex="14" CssClass="txtgvItemSearch" Style="display: inline-block; width: 100%; background-image: url('../Images/Search.png'); background-position: right; margin-left: 0px; background-repeat: no-repeat" />
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12">

                    <asp:GridView runat="server" ID="gvOrder" CssClass="gvOrder nowrap table" AutoGenerateColumns="false" Style="border-collapse: collapse;" Font-Size="11px" HeaderStyle-CssClass="table-header-gradient" OnPreRender="gvOrder_Prerender">
                        <Columns>
                            <asp:TemplateField HeaderText="Sr." HeaderStyle-CssClass="dtbodyCenter">
                                <ItemTemplate>
                                    <asp:Label ID="lblNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Label>
                                </ItemTemplate>
                                <ItemStyle HorizontalAlign="Center" />
                                <HeaderStyle HorizontalAlign="Right" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Check" HeaderStyle-CssClass="dtbodyCenter" HeaderStyle-Width="60px">
                                <HeaderTemplate>
                                    <input type="checkbox" name="chkhead" class="chkhead" id="chkhead" runat="server" onchange="ClickHead(this);" />
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <input type="checkbox" name="chkCheck" class="chkCheck" id="chkcheck" runat="server" onchange="ReloadRadio();" />
                                </ItemTemplate>
                                <ItemStyle HorizontalAlign="Center" />
                                <HeaderStyle HorizontalAlign="Center" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Code" HeaderStyle-Width="84px" HeaderStyle-HorizontalAlign="Left">
                                <ItemTemplate>
                                    <asp:Label ID="lblober" Text='<%# Eval("CustomerCode") %>' runat="server" CssClass="tdleftalign"></asp:Label>
                                    <asp:Label ID="lblOFSSIID" Text='<%# Eval("OFSSIID") %>' runat="server" Visible="false" CssClass="tdleftalign"></asp:Label>
                                </ItemTemplate>
                                <ItemStyle HorizontalAlign="Left" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Name" ItemStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" HeaderStyle-HorizontalAlign="Left">
                                <ItemTemplate>
                                    <asp:Label ID="lblnber" Text='<%# Eval("CustomerName") %>' runat="server" CssClass="tdleftalign"></asp:Label>
                                </ItemTemplate>
                                <ItemStyle HorizontalAlign="Left" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="City" ItemStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" HeaderStyle-HorizontalAlign="Left">
                                <ItemTemplate>
                                    <asp:Label ID="lblTotalInvoice" runat="server" Text='<%# Eval("CityName") %>' CssClass="tdleftalign"></asp:Label>
                                </ItemTemplate>
                                <ItemStyle HorizontalAlign="Left" />
                                <HeaderStyle HorizontalAlign="Left" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Region" ItemStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" HeaderStyle-HorizontalAlign="Left">
                                <ItemTemplate>
                                    <asp:Label ID="lblVehicleNo" Text='<%# Eval("RegionDesc") %>' runat="server" CssClass="tdleftalign"></asp:Label>
                                </ItemTemplate>
                                <ItemStyle HorizontalAlign="Left" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="FSSI NO" ItemStyle-CssClass="dtbodyRight" HeaderStyle-HorizontalAlign="Left">
                                <ItemTemplate>
                                    <asp:Label ID="lblCust" Text='<%# Eval("FSSINO") %>' runat="server" CssClass="tdleftalign"></asp:Label>
                                </ItemTemplate>
                                <ItemStyle HorizontalAlign="Right" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Start Date" HeaderStyle-CssClass="dtbodyCenter">
                                <ItemTemplate>
                                    <asp:Label ID="lblStartDate" Text='<%# Eval("StartDate") %>' runat="server" CssClass="tdrightalign"></asp:Label>
                                </ItemTemplate>
                                <ItemStyle HorizontalAlign="Center" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="End Date" HeaderStyle-CssClass="dtbodyCenter">
                                <ItemTemplate>
                                    <asp:Label ID="lblEndDate" Text='<%# Eval("EndDate") %>' runat="server" CssClass="tdrightalign"></asp:Label>
                                </ItemTemplate>
                                <ItemStyle HorizontalAlign="Center" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Image" ItemStyle-VerticalAlign="Middle">
                                <ItemTemplate>
                                    <%-- <asp:Button ID="lblimg" Text="View Image" CommandName="Image" runat="server" CommandArgument="<%# Container.DataItemIndex %>"></asp:Button>--%>
                                    <a href='<%# Eval("FSSIImagePath") %>' target="_blank">View Image</a>
                                </ItemTemplate>
                            </asp:TemplateField>
                             <asp:TemplateField HeaderText="Remarks" ItemStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" HeaderStyle-HorizontalAlign="Left">
                                <ItemTemplate>
                                    <asp:TextBox ID="txtTextRemarks" runat="server" CssClass="tdleftalign" MaxLength="25"></asp:TextBox>
                                </ItemTemplate>
                                <ItemStyle HorizontalAlign="Left" />
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>


            </div>
        </div>
    </div>
</asp:Content>

