<%@ Page Title="" Language="C#" MasterPageFile="~/MainMaster.master" AutoEventWireup="true" CodeFile="ClaimFwd.aspx.cs" Inherits="Master_ClaimFwd" %>

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
            ChangeReportFor('1');
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
            //$('.gvOrder').tableHeadFixer('65vh');
            //$('.divCustEntry').tableHeadFixer('65vh');
            $(".gvOrder").tableHeadFixer('52vh');


            //// Start Search Employee

            $(document).on('keyup', '.AutoEmpName', function () {
                var textValue = $(this).val();
                //var currentRow = $(this).closest("tr");
                //var col1 = currentRow.find("td:eq(0)").text();
                //var txtId = $(this).attr("id");
                //var col1 = txtId.replace("AutoEmpName", '');
                $(this).autocomplete({
                    source: function (request, response) {
                        //var RegionId = $("#AutoRegion" + col1).val() != "" && $("#AutoRegion" + col1).val() != undefined ? $("#AutoRegion" + col1).val().split("-")[2].trim() : "0";
                        var RegionId = 0;
                        $.ajax({
                            type: "POST",
                            url: 'EmpClaimLevelEntry.aspx/SearchEmployee',
                            dataType: "json",
                            data: "{ 'prefixText': '" + (textValue != '' ? textValue : '*') + "','strRegionId':'" + RegionId + "'}",
                            contentType: "application/json; charset=utf-8",
                            success: function (result) {
                                if (result.d == "") {
                                    return false;
                                }
                                else {
                                    response(result.d[0]);
                                }
                            },
                            error: function (XMLHttpRequest, textStatus, errorThrown) {
                            }
                        });
                    },
                    position: {
                        my: 'left top',
                        at: 'right top',
                        collision: 'flip flip',
                        of: $(this),
                        using: function (obj, info) {
                            if (info.vertical != "top") {
                                $(this).addClass("flipped");
                            } else {
                                $(this).removeClass("flipped");
                            }
                            if (info.horizontal != "left") {
                                $(this).addClass("flipped");
                            } else {
                                $(this).removeClass("flipped");
                            }
                            $(this).css({
                                left: obj.left + 'px',
                                top: obj.top + 'px'
                            });
                        }
                    },
                    select: function (event, ui) {
                        $(this).val(ui.item.value + " ");
                        // $('#hdnEmpId' + col1).val(ui.item.value.split("#")[2].trim());
                    },
                    change: function (event, ui) {
                        if (!ui.item) {

                        }
                    },
                    minLength: 1
                });
            });

            $(this).on('autocompleteselect', function (e, ui) {
                var currentRow = $(this).closest("tr");
                var col1 = currentRow.find("td:eq(0)").text();
                $(this).val(ui.item.value);

            });

            $(this).on('change keyup', function () {
                //var txtId = $(this).attr("id");
                //var col1 = txtId.replace("AutoEmpName", '');
                if ($(this).val() == "") {

                }
            });

            $(this).on('blur', function (e, ui) {
                //var txtId = $(this).attr("id");
                //var col1 = txtId.replace("AutoEmpName", '');
                if ($(this) != "") {
                    if ($(this).val().indexOf('#') == -1) {
                        ModelMsg("Select Proper Employee Name", 3);
                        $(this).val("");
                        return;
                    }
                    var txt = $(this).val().trim();
                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                }
            });

            ////End Employee Textbox
        });

        function EndRequestHandler2(sender, args) {
            ReLoadFn();
            ChangeReportFor('1');
        }



        $(document).ready(function () {
            $('.gvOrder').DataTable();       //capital "D"
        });
        function ReLoadFn() {
            var table = $('.gvOrder').DataTable();
            var aryJSONColTable = [];

            aryJSONColTable.push({ "bSortable": "false", "width": "30px", "sClass": "dtbodyCenter", "aTargets": 0 });
            aryJSONColTable.push({ "bSortable": "false", "width": "20px", "sClass": "dtbodyCenter", "aTargets": 1 });
            aryJSONColTable.push({ "bSortable": "false", "width": "120px", "aTargets": 2 });
            aryJSONColTable.push({ "bSortable": "false", "width": "30px", "aTargets": 3 });//"sClass": "dtbodyLeft",
            aryJSONColTable.push({ "bSortable": "false", "width": "60px", "aTargets": 4 });
            aryJSONColTable.push({ "bSortable": "false", "width": "35px", "aTargets": 5 });
            aryJSONColTable.push({ "bSortable": "false", "width": "100px", "aTargets": 6 });
            aryJSONColTable.push({ "bSortable": "false", "width": "30px", "aTargets": 7 });//"sClass": "dtbodyLeft",
            aryJSONColTable.push({ "bSortable": "false", "width": "70px", "aTargets": 8 });//"sClass": "dtbodyLeft",

            setTimeout(function () {
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
                    async: false,
                });
            }, 100);
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
        function ChangeReportFor(ReportBy) {
        }
        function ClickHead(chk) {
            var myHidden = document.getElementById('<%= hdnFwdUser.ClientID %>').value;
            if ($(chk).is(':checked')) {
                $('.chkCheck').prop('checked', true);
                $('.AutoEmpName').val(myHidden);
            }
            else {
                $('.chkCheck').prop('checked', false);
                $('.AutoEmpName').val('');
            }
        }
        function ReloadRadio(chk) {
            if ($('.chkCheck').length == $('.chkCheck:checked').length)
                $('.chkhead').prop('checked', true);
            else
                $('.chkhead').prop('checked', false);
            var chkid = $(chk).attr('id');
            var txtname = "body_gvOrder_AutoEmpName" + chkid.substring(chkid.lastIndexOf('_'), chkid.length);
            if ($(chk).is(':checked')) {
                var myHidden = document.getElementById('<%= hdnFwdUser.ClientID %>').value;
                $("#" + txtname).val(myHidden);
            }
            else {
                $("#" + txtname).val('');
            }



        }
        function _btnCheck() {
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            IsValid = $('._masterForm').data('bootstrapValidator').isValid();
        }
        function autoCompleteState_OnClientPopulating(sender, args) {
            var countryId = 1;
            sender.set_contextKey(countryId);
        }

    </script>
    <style>
        #body_gvOrder_wrapper .dataTables_scrollBody {
            overflow-x: hidden !important;
            overflow-y: auto !important;
        }

        #page-content-wrapper {
            overflow: hidden;
        }

        .dataTables_scrollHeadInner {
            width: auto;
        }

        .dataTables_scrollBody {
            overflow-x: hidden !important;
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

        .table > thead > tr > th, .table > tbody > tr > th, .table > tfoot > tr > th, .table > thead > tr > td, .table > tbody > tr > td, .table > tfoot > tr > td {
            /*padding-left: 4px !important;*/
            padding: 0px !important;
            vertical-align: middle !important;
            /*white-space: nowrap;*/
            /*overflow-x: scroll;*/
        }

        .tdleftalign {
            margin-left: 2px !important;
        }

        .tdrightalign {
            margin-right: 2px !important;
        }

        .CustName {
            /*overflow: auto;*/
            white-space: nowrap;
            overflow-x: scroll;
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

        .dataTables_scrollFoot {
            display: none;
        }

        @media (min-width: 768px) {
            .container {
                max-width: 100%;
            }
        }

        @media (min-width: 1200px) {
            .container {
                width: 1073px;
            }
        }

        @media (min-width: 992px) {
            .container {
                max-width: 100%;
            }
        }

        @media (min-width: 1200px) {
            /*.dataTables_scrollHead {
                width: 1000px !important;
            }

            #body_gvOrder_wrapper .dataTables_scrollHead {
                width: 1000px !important;
            }*/

            #body_gvOrder_wrapper .dataTables_scrollBody {
                width: 1050px !important;
                /*margin-left:-145px !important;*/
            }
            /*#body_gvOrder_wrapper .dataTables_scrollFootInner {
                width: 1000px !important;
            }
                 #body_gvOrder_wrapper .dataTables_scrollFoot {
                width: 1000px !important;
            }*/
        }

        .AutoEmpName {
            height: 24px !important;
            font-size: 10px !important;
        }

        .dtLeftAlign {
            margin-left: 3px !important
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <asp:HiddenField ID="hdnFwdUser" runat="server" />
    <asp:ToolkitScriptManager ID="tsm" runat="server" CombineScripts="true" EnablePageMethods="true" AsyncPostBackTimeout="36000" ClientIDMode="AutoID"></asp:ToolkitScriptManager>
    <div class="panel">
        <div class="panel-body _masterForm">
            <div class="row">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblSaleBy" Text="Report By" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlReportBy" TabIndex="1" CssClass="ddlReportBy form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlReportBy_SelectedIndexChanged">
                            <asp:ListItem Text="Super Stockist" Value="4" />
                            <asp:ListItem Text="Distributor" Value="2" Selected="True" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="Label1" runat="server" Text="Region" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtRegion" CssClass="txtRegion form-control" TabIndex="6" runat="server" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender1" runat="server" ServiceMethod="GetIndianStates"
                            ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1"
                            TargetControlID="txtRegion" UseContextKey="True" OnClientPopulating="autoCompleteState_OnClientPopulating">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                 <div class="col-lg-4">
                     <div class="input-group form-group">
                      <asp:Label ID="Label2" runat="server" Text="Claim Shown after Jan-2020" ForeColor="Red" Font-Bold="true" CssClass="input-group-addon"></asp:Label>
                         </div>
                     </div>
            </div>
            <div class="row">
                <div class="col-lg-8">
                    <asp:Button ID="btnSearch" runat="server" Text="Search" TabIndex="3" CssClass="btn btn-default" OnClientClick="return _btnCheck();" OnClick="btnSearch_Click" />
                    <asp:Button ID="btnGenerat" runat="server" Text="Submit" TabIndex="4" CssClass="btn btn-info" OnClick="btnGenerat_Click" />
                </div>
                <div class="col-lg-4">
                    <asp:TextBox runat="server" placeholder="Search here" ID="txtgvItemSearch" TabIndex="5" CssClass="txtgvItemSearch" Style="display: inline-block; width: 100%; background-image: url('../Images/Search.png'); background-position: right; margin-left: 0px; background-repeat: no-repeat" />
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12">
                    <div id="divEmpDiscountEntry" class="divEmpDiscountEntry" runat="server" style="max-height: 50vh;">
                        <asp:GridView runat="server" ID="gvOrder" CssClass="gvOrder nowrap table" Width="100%" AutoGenerateColumns="false" Style="border-collapse: collapse;" Font-Size="11px" HeaderStyle-CssClass="table-header-gradient" OnPreRender="gvOrder_Prerender">
                            <Columns>
                                <asp:TemplateField HeaderText="Sr." HeaderStyle-CssClass="dtbodyCenter">
                                    <ItemTemplate>
                                        <asp:Label ID="lblNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Label>
                                        <asp:Label ID="lblParentId" runat="server" Visible="false" Text='<%# Eval("ParentID") %>'></asp:Label>
                                        <asp:Label ID="lblParentClaimId" runat="server" Visible="false" Text='<%# Eval("ParentClaimID") %>'></asp:Label>
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Center" />
                                    <HeaderStyle HorizontalAlign="Right" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Check" HeaderStyle-CssClass="dtbodyCenter" HeaderStyle-Width="60px">
                                    <HeaderTemplate>
                                        <input type="checkbox" name="chkhead" class="chkhead" id="chkhead" runat="server" onchange="ClickHead(this);" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <input type="checkbox" name="chkCheck" class="chkCheck" id="chkcheck" runat="server" onchange="ReloadRadio(this);" />
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Center" />
                                    <HeaderStyle HorizontalAlign="Center" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Dist / SS" HeaderStyle-HorizontalAlign="Left">
                                    <ItemTemplate>
                                        <asp:Label ID="lblober" Text='<%# Eval("CustomerName") %>' runat="server" CssClass="tdleftalign"></asp:Label>
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Left" CssClass="CustName" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Active" HeaderStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:Label ID="lblActive" Text='<%# Eval("IsActive") %>' runat="server" CssClass="dtbodyCenter"></asp:Label>
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Center" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="City" HeaderStyle-Width="57px" HeaderStyle-CssClass="dtLeftAlign">
                                    <ItemTemplate>
                                        <asp:Label ID="lblndate" Text='<%# Eval("CityName") %>' runat="server" CssClass="dtLeftAlign"></asp:Label>
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Left" />
                                    <HeaderStyle HorizontalAlign="Left" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Year Month" HeaderStyle-Width="80px">
                                    <ItemTemplate>
                                        <asp:Label ID="lblnber" Text='<%# Eval("YearMonth") %>' runat="server" CssClass="tdleftalign"></asp:Label>
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Left" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Claim Type" HeaderStyle-Width="99px">
                                    <ItemTemplate>
                                        <asp:Label ID="lblTotalInvoice" runat="server" Text='<%# Eval("ClaimType") %>'></asp:Label>
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Left" CssClass="CustName" />
                                    <HeaderStyle HorizontalAlign="Left" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Claim Amount" HeaderStyle-CssClass="dtbodyRight">
                                    <ItemTemplate>
                                        <asp:Label ID="lblQty" Text='<%# Eval("ClaimAmount","{0:0}") %>' runat="server" CssClass="tdrightalign"></asp:Label>
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Right" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Forward To">
                                    <ItemTemplate>
                                        <asp:TextBox ID="AutoEmpName" runat="server" CssClass="form-control AutoEmpName" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Left" />
                                    <HeaderStyle HorizontalAlign="Left" />
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>

                </div>
            </div>
        </div>
    </div>
</asp:Content>

