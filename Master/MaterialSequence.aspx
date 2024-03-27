<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="MaterialSequence.aspx.cs" Inherits="Master_MaterialSequence" %>

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
    <link href="https://cdn.datatables.net/scroller/2.0.7/css/scroller.dataTables.min.css" rel="stylesheet" />


    <script type="text/javascript">
        $(function () {
            var GridView = $('#gvMaterial').DataTable({});

            $('#gvMaterial').show();
            GridView.columns.adjust().draw();
            Relaod();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
            $(".gvMaterial").tableHeadFixer('48vh');
        });

        function EndRequestHandler2(sender, args) {
            Relaod();
        }
        function _btnCheck() {
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            return $('._masterForm').data('bootstrapValidator').isValid();
        }
        function ChangePriority(txt) {
            var maxValue = 0;
            var RowIdex = 0;
            var num = 0;
            var main = $('.gvMaterial');
            var AllRows = $(main).find('tbody').find('tr');

            for (var i = 0; i < AllRows.length; i++) {
                num = Number($(AllRows[i]).find('[id *= ' + txt + ']').val());
                if (num > maxValue) {
                    maxValue = num;
                    RowIdex = i;
                }
            }

            for (var i = RowIdex; i < AllRows.length; i++) {
                if (Number($(AllRows[i]).find('[id *= ' + txt + ']').val()) <= 0) {
                    $(AllRows[i]).find('[id *= ' + txt + ']').val(++maxValue);
                }
            }
            for (var j = RowIdex; j >= 0; j--) {
                if (Number($(AllRows[j]).find('[id *= ' + txt + ']').val()) <= 0) {
                    $(AllRows[j]).find('[id *= ' + txt + ']').val(++maxValue);
                }
            }
        }

        function ClearPr(txt) {
            var main = $('.gvMaterial');
            var AllRows = $(main).find('tbody').find('tr');

            for (var i = 0; i < AllRows.length; i++) {
                $(AllRows[i]).find('[id *= ' + txt + ']').val('');
            }
        }

        function CheckMain(chk) {
            if (chk == undefined) {
                if ($('.chkCheck').length == $('.chkCheck:checked').length)
                    $('.chkMain').prop('checked', true);
                else
                    $('.chkMain').prop('checked', false);
            }
            else {
                if ($(chk).is(':checked')) {
                    $('.chkCheck').prop('checked', true);
                }
                else {
                    $('.chkCheck').prop('checked', false);
                }
            }
        }
        function twidth() {
            //   $('.tdiv').css('max-height', (innerHeight - 100) + "px");
        }
        window.onresize = twidth;
        function Relaod() {
            twidth();
            //var table = $('.gvMaterial').DataTable();

            var aryJSONColTable = [];
            aryJSONColTable.push({ "width": "40px", "sClass": "dtbodyCenter", "aTargets": 0 });
            aryJSONColTable.push({ "width": "100px", "aTargets": 1 });
            aryJSONColTable.push({ "width": "100px", "aTargets": 2 });
            aryJSONColTable.push({ "width": "80px", "aTargets": 3 });
            aryJSONColTable.push({ "width": "200px", "aTargets": 4 });
            aryJSONColTable.push({ "width": "60px", "aTargets": 5 });
            aryJSONColTable.push({ "width": "30px", "sClass": "dtbodyCenter", "aTargets": 6 });

            setTimeout(function () {
                var table = $('#<%= gvMaterial.ClientID %>').prepend($("<thead></thead>").append($('#<%= gvMaterial.ClientID %>').find("tr:first"))).DataTable({
                    bFilter: false,
                    scrollCollapse: true,
                    "sExtends": "collection",
                    scrollX: false,
                    scrollY: '48vh',
                    responsive: true,
                    "bPaginate": false,
                    ordering: false,
                    "bInfo": true,
                    "autoWidth": false,
                    destroy: true,
                    deferRender: true,
                    "aoColumnDefs": aryJSONColTable,
                });
            }, 200)
            //new $.fn.dataTable.FixedHeader(table);

            //    $('.dataTables_scrollFoot').css('overflow', 'auto');
            $(".txtSearch").keyup(function () {
                var word = this.value;
                $(".gvMaterial > tbody tr").each(function () {
                    if ($(this).find("td").text().toUpperCase().indexOf(word.toUpperCase()) >= 0)
                        $(this).show();
                    else
                        $(this).hide();
                });
            });
        }

    </script>
    <style>
        #page-content-wrapper {
            overflow: hidden;
        }

        /*.dataTables_scrollHeadInner {
            width: auto;
            position: fixed;
            display: block;
            overflow: hidden;
        }*/

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
            margin-right: 2px !important;
        }

        .dtbodyCenter {
            text-align: center !important;
        }

        div.dataTables_wrapper {
            margin: 0 auto;
        }

        table.gvMaterial tbody tr td {
            height: 25px !important;
            padding: 1px !important;
            vertical-align: middle;
        }

        .txtPriority {
            height: 20px !important;
            text-align: right !important;
        }

        .table {
            font-size: 11px !important;
        }

            .table > thead > tr > th, .table > tbody > tr > th, .table > tfoot > tr > th, .table > thead > tr > td, .table > tbody > tr > td, .table > tfoot > tr > td {
                /*padding-left: 4px !important;*/
                /*padding: 0px 0 0 4px !important;*/
                padding: 0px;
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
            padding-left: 4px !important;
        }

            .CustName::-webkit-scrollbar {
                display: none;
            }

        .CustName {
            -ms-overflow-style: none; /* IE and Edge */
            scrollbar-width: none; /* Firefox */
        }

        .input-group form-group, .ddlDivision, .chkDefault, .chkActive, .txtTName, .txtTNo, .input-group-addon {
            height: 25px !important;
            font-weight: bold;
            font-size: 12px !important;
        }

        input[type=radio], input[type=checkbox] {
            margin: -1px 0 0 !important;
        }

        .form-control {
            padding: 4px 12px !important;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div style="margin-left: 15px">
        <input type="checkbox" name="onoffswitch" class="_auchk" onchange="javascript: setTimeout('__doPostBack(\'\',\'\')', 0)" data-size="large" data-on-text="Add" data-off-text="Update" clientidmode="Static" id="chkMode" runat="server" checked="checked" onserverchange="chkMode_Checked" />
    </div>
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:label text="Template No" runat="server" cssclass="input-group-addon" />
                        <asp:textbox runat="server" id="txtTNo" autopostback="true" ontextchanged="txtTNo_TextChanged" cssclass="form-control txtTNo" />
                        <asp:autocompleteextender onclientshown="resetPosition" completionlistcssclass="CompletionListClass" id="ACEtxtName" runat="server" servicepath="../WebService.asmx"
                            usecontextkey="true" servicemethod="GetSITM" minimumprefixlength="1" completioninterval="10"
                            enablecaching="false" completionsetcount="1" targetcontrolid="txtTNo">
                        </asp:autocompleteextender>
                    </div>
                    <div class="input-group form-group">
                        <asp:label text="Template Name" runat="server" cssclass="input-group-addon" />
                        <asp:textbox runat="server" id="txtTName" maxlength="150" cssclass="form-control txtTName" data-bv-notempty="true" data-bv-notempty-message="Field is required" onkeyup="enter(this);" onkeypress="return iswithoutminus(event);" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:label text="Default" runat="server" cssclass="input-group-addon" />
                        <asp:checkbox runat="server" id="chkDefault" cssclass="form-control chkDefault" autopostback="true" oncheckedchanged="ddlDivision_SelectedIndexChanged" />
                    </div>
                    <div class="input-group form-group">
                        <asp:label text="Active" runat="server" cssclass="input-group-addon" />
                        <asp:checkbox runat="server" id="chkActive" cssclass="form-control chkActive" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:label text="Division" runat="server" cssclass="input-group-addon" />
                        <asp:dropdownlist id="ddlDivision" autopostback="true" runat="server" cssclass="ddlDivision form-control" onselectedindexchanged="ddlDivision_SelectedIndexChanged"></asp:dropdownlist>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:button id="btnSubmit" runat="server" text="Submit" cssclass="btn btn-default" onclick="btnSubmitClick" onclientclick="return _btnCheck();" />
                        <asp:button id="btnCancel" runat="server" text="Cancel" cssclass="btn btn-default" onclick="btnCancelClick" usesubmitbehavior="false" causesvalidation="false" />
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="row">
        <div class="col-lg-12">
            <asp:textbox runat="server" placeholder="Search here" cssclass="txtSearch form-control" />
        </div>
        <%-- <div class="col-lg-1" style="padding-left: 0px; padding-right: 0px">
            <asp:Label Text="Is Active" ID="lblActive" runat="server" Font-Bold="true" Style="width: 70px; vertical-align: text-bottom;" />
            <asp:CheckBox ID="chkIsActive" runat="server" OnCheckedChanged="txtTNo_TextChanged" AutoPostBack="true" Checked="true" />
        </div>--%>
    </div>

    <div class="row">
        <div class="col-lg-12">
            <div style="overflow-x: auto; overflow-y: auto; max-height: 62vh" class="tdiv">
                <asp:gridview id="gvMaterial" runat="server" autogeneratecolumns="false" cssclass="gvMaterial table table-striped table-bordered table-responsive table-hover cell-border compact webgrid-table-hidden" onprerender="gvMaterial_PreRender" width="100%" emptydatatext="No Item Found." headerstyle-cssclass="table-header-gradient">
                    <Columns>
                        <asp:TemplateField HeaderText="No" ItemStyle-HorizontalAlign="Center">
                            <HeaderTemplate>
                                <asp:Label Text="No" runat="server" />
                            </HeaderTemplate>
                            <ItemTemplate>
                                <asp:Label ID="lblNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Label>
                            </ItemTemplate>
                            <HeaderStyle Width="4%" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Priority">
                            <ItemTemplate>
                                <asp:TextBox ID="txtPriority" CssClass="form-control txtPriority" runat="server" Text='<%# Eval("Priority").ToString() == "0" ? "" : Eval("Priority") %>'
                                    onkeyup="enter(this);" onBlur="ResetColor()" onFocus="ChangeColor()" onkeypress="return isNumberKey(event);"></asp:TextBox>
                            </ItemTemplate>
                            <HeaderTemplate>
                                <asp:Label Text="Priority" runat="server" /><br />
                                <asp:LinkButton Text="Set" runat="server" ID="lnkChPriority" OnClientClick="ChangePriority('txtPriority'); return false;"
                                    CssClass="lnk_btn_table btn btn-default" />
                                <asp:LinkButton Text="Clear" runat="server" ID="lnkCPriority" OnClientClick="ClearPr('txtPriority'); return false;"
                                    CssClass="lnk_btn_table btn btn-default" />
                            </HeaderTemplate>
                            <HeaderStyle Width="12%" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Division">
                            <HeaderTemplate>
                                <asp:Label Text="Division" runat="server" />
                            </HeaderTemplate>
                            <ItemTemplate>
                                <asp:Label ID="lblIDivision" runat="server" Text='<%# Eval("Division") %>'></asp:Label>
                            </ItemTemplate>
                            <HeaderStyle Width="14%" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Item Code">
                            <HeaderTemplate>
                                <asp:Label Text="Item Code" runat="server" />
                            </HeaderTemplate>
                            <ItemTemplate>
                                <asp:Label ID="lblItemCode" runat="server" Text='<%# Eval("ItemCode") %>'></asp:Label>
                            </ItemTemplate>
                            <HeaderStyle Width="14%" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Item Name">
                            <HeaderTemplate>
                                <asp:Label Text="Item Name" runat="server" />
                            </HeaderTemplate>
                            <ItemTemplate>
                                <asp:Label ID="lblItemID" runat="server" Text='<%# Eval("ItemID") %>' Visible="false"></asp:Label>
                                <asp:Label ID="lblItemName" runat="server" Text='<%# Eval("ItemName") %>'></asp:Label>
                            </ItemTemplate>
                            <ItemStyle CssClass="CustName" />
                            <HeaderStyle Width="15%" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Unit Name">
                            <HeaderTemplate>
                                <asp:Label Text="Unit Name" runat="server" />
                            </HeaderTemplate>
                            <ItemTemplate>
                                <asp:Label ID="lblUnitName" runat="server" Text='<%# Eval("UnitName") %>'></asp:Label>
                            </ItemTemplate>
                            <ItemStyle Width="5%" />
                            <HeaderStyle Width="5%" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Is Active">
                            <HeaderTemplate>
                                <input type="checkbox" name="chkMain" id="chkMain" class="chkMain" runat="server" onchange="CheckMain(this);" />
                            </HeaderTemplate>
                            <ItemTemplate>
                                <input type="checkbox" name="chkCheck" id="chkCheck" class="chkCheck" runat="server" onchange="CheckMain();" checked='<%#Convert.ToBoolean(Eval("Active"))%>' />
                            </ItemTemplate>
                            <HeaderStyle Width="3%" />
                        </asp:TemplateField>
                    </Columns>
                </asp:gridview>
            </div>
        </div>
    </div>
    <div class="ui-grid-a" style="margin-left: 3.5%; margin-top: 1%; display: none;">
        <div style="padding-bottom: 10px; padding-top: 10px;">
        </div>
    </div>
</asp:Content>

