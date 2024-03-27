<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="AttendenceRpt.aspx.cs" Inherits="Reports_AttendenceRpt" %>

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

    <script type="text/javascript">

        function ViewDetails(EntryNo) {
            $.colorbox({
                width: '95%',
                height: '95%',
                iframe: true,
                href: 'AttendenceDetails.aspx?EntryID=' + EntryNo
            });
        }


        $(function () {
            Reload();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {

            Reload();
        }

        function acettxtEmployeeCode_OnClientPopulating(sender, args) {
            var key = $('.ddlEGroup').val();
            sender.set_contextKey(key);
        }

        function _btnCheck() {

            var IsValid = true;

            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            IsValid = $('._masterForm').data('bootstrapValidator').isValid();
            return IsValid;
        }


        function ExportXLS(xlsx, numrows) {
            var sheet = xlsx.xl.worksheets['sheet1.xml'];
            var clR = $('row', sheet);

            //update Row
            clR.each(function () {
                var attr = $(this).attr('r');
                var ind = parseInt(attr);
                ind = ind + numrows;
                $(this).attr("r", ind);
            });

            // Create row before data
            $('row c ', sheet).each(function () {
                var attr = $(this).attr('r');
                var pre = attr.substring(0, 1);
                var ind = parseInt(attr.substring(1, attr.length));
                ind = ind + numrows;
                $(this).attr("r", pre + ind);
            });

            return sheet;
        }

        function Addrow(index, data) {
            msg = '<row r="' + index + '">'
            for (i = 0; i < data.length; i++) {
                var key = data[i].key;
                var value = data[i].value;
                msg += '<c t="inlineStr" r="' + key + index + '">';
                msg += '<is>';
                if (value != "" && Array.isArray(value))
                    value = value[0].replace(/&/g, '&amp;') + value[1].replace(/&/g, '&amp;');
                else
                    value = value.replace(/&/g, '&amp;');
                msg += '<t>' + value + '</t>';
                msg += '</is>';
                msg += '</c>';
            }
            msg += '</row>';
            return msg;
        }


        function Reload() {

            $('.OrderMap').click(function () {

                var empcode = $(this).parent().parent().children()[0].innerText.split("-")[0].trim();
                var date = $(this).parent().parent().children()[2].innerText;

                var currentdate = '<%=DateTime.Now.ToString("MM/dd/yyyy")%>';
                var formatdate = (date.split("/")[1] + "/" + date.split("/")[0] + "/" + date.split("/")[2])

                if (new Date(currentdate) < new Date(formatdate)) {
                    alert('Selected Date is greater than Current Date');
                    return;
                }
                window.open("../Reports/OrderMap.aspx?EmpCode=" + empcode + "&Date=" + date);
            });

            if ($('.gvattendence thead tr').length > 0) {

                var now = new Date();
                Date.prototype.today = function () {
                    return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
                }
                var jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: true });

                $('.gvattendence').DataTable(
                    {
                        bFilter: true,
                        scrollCollapse: true,
                        destroy: true,
                        scrollY: '50vh',
                        scrollX: true,
                        responsive: true,
                        dom: 'Bfrtip',
                        "stripeClasses": ['odd-row', 'even-row'],
                        "bPaginate": false,
                        buttons: [{ extend: 'copy', footer: true },
                            {
                                extend: 'csv', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(), header: $("#lnkTitle").text(),
                                customize: function (csv) {
                                    var data = 'Date wise Daily Activities Summary Report For : ' + $('.txtCode').val() + '\n';
                                    data += 'From Date,' + $('.fromdate').val() + ',To Date,' + $('.todate').val() + '\n';
                                    data += 'Employee,' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val() : "All Employee") + '\n';
                                    data += 'Employee Group,' + (($('.ddlEGroup').val() > 0 && $('.ddlEGroup').val() != "") ? $('.ddlEGroup option:Selected').text() : "All Employee Group") + '\n';
                                    data += 'User Name,' + $('.hdnUserName').val() + '\n';
                                    data += 'Created on,' + jsDate.toString() + '\n';
                                    return data + csv;
                                },
                                exportOptions: {
                                    columns: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14],
                                    format: {
                                        body: function (data, row, column, node) {
                                            //check if type is input using jquery
                                            return (data == "&nbsp;" || data == "") ? " " : data.replace(/<br[^>]*>/g, " ");
                                        }
                                    }
                                }
                            },
                            {
                                extend: 'excel', footer: true, header: $("#lnkTitle").text(), filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                                customize: function (xlsx) {

                                    sheet = ExportXLS(xlsx, 7);

                                    var r0 = Addrow(1, [{ key: 'A', value: 'Date wise Daily Activities Summary Report For' }, { key: 'B', value: $('.txtCode').val() }]);
                                    var r1 = Addrow(2, [{ key: 'A', value: 'From Date' }, { key: 'B', value: $('.fromdate').val() }, { key: 'C', value: 'To Date' }, { key: 'D', value: $('.todate').val() }]);
                                    var r2 = Addrow(3, [{ key: 'A', value: 'Employee' }, { key: 'B', value: (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val() : "All Employee") }]);
                                    var r3 = Addrow(4, [{ key: 'A', value: 'Employee Group' }, { key: 'B', value: (($('.ddlEGroup').val() > 0 && $('.ddlEGroup').val() != "") ? $('.ddlEGroup option:Selected').text() : "All Employee Group") }]);
                                    var r4 = Addrow(5, [{ key: 'A', value: 'User Name' }, { key: 'B', value: $('.hdnUserName').val() }]);
                                    var r5 = Addrow(6, [{ key: 'A', value: 'Created on' }, { key: 'B', value: jsDate.toString() }]);

                                    sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r3 + r4 + r5 + sheet.childNodes[0].childNodes[1].innerHTML;
                                },
                                exportOptions: {
                                    columns: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]
                                }
                            },
                            {
                                extend: 'pdfHtml5',
                                orientation: 'landscape', //portrait
                                pageSize: 'A4', //A3 , A5 , A6 , legal , letter
                                title: $("#lnkTitle").text(),

                                exportOptions: {
                                    columns: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14],
                                    search: 'applied',
                                    order: 'applied'
                                },
                                customize: function (doc) {
                                    doc.content.splice(0, 1);

                                    doc.pageMargins = [20, 90, 20, 30];
                                    doc.defaultStyle.fontSize = 7;
                                    doc.styles.tableHeader.fontSize = 7;
                                    doc['header'] = (function () {
                                        return {
                                            columns: [
                                                {
                                                    alignment: 'left',
                                                    italics: true,
                                                    text: [{ text: 'Date wise Daily Activities Summary Report For : ' + $('.txtCode').val() + "\n" },
                                                    { text: 'From Date : ' + $('.fromdate').val() + '\t To Date : ' + $('.todate').val() + "\n" },
                                                    { text: 'Employee : ' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val() + "\n" : "All Employee\n") },
                                                    { text: 'Employee Group : ' + (($('.ddlEGroup').val() > 0 && $('.ddlEGroup').val() != "") ? $('.ddlEGroup option:Selected').text() + "\n" : "All Employee Group\n") },
                                                    { text: 'User Name : ' + $('.hdnUserName').val() + "\n" }],
                                                    fontSize: 10,
                                                    height: 500,
                                                }
                                            ],
                                            margin: 20
                                        }
                                    });
                                    doc['footer'] = (function (page, pages) {
                                        return {
                                            columns: [
                                                {
                                                    alignment: 'left',
                                                    text: ['Created on: ', { text: jsDate.toString() }]
                                                },
                                                {
                                                    alignment: 'right',
                                                    text: ['page ', { text: page.toString() }, ' of ', { text: pages.toString() }]
                                                }
                                            ],
                                            margin: 20
                                        }
                                    });

                                    var objLayout = {};
                                    objLayout['hLineWidth'] = function (i) { return .5; };
                                    objLayout['vLineWidth'] = function (i) { return .5; };
                                    objLayout['hLineColor'] = function (i) { return '#000'; };
                                    objLayout['vLineColor'] = function (i) { return '#000'; };
                                    objLayout['paddingLeft'] = function (i) { return 4; };
                                    objLayout['paddingRight'] = function (i) { return 4; };
                                    doc.content[0].layout = objLayout;

                                    var rowCount = doc.content[0].table.body.length;
                                    for (i = 1; i < rowCount; i++) {
                                        doc.content[0].table.body[i][2].alignment = 'center';
                                        doc.content[0].table.body[i][3].alignment = 'right';
                                        doc.content[0].table.body[i][4].alignment = 'center';
                                        doc.content[0].table.body[i][5].alignment = 'right';
                                        doc.content[0].table.body[i][10].alignment = 'right';
                                        doc.content[0].table.body[i][12].alignment = 'right';
                                        doc.content[0].table.body[i][13].alignment = 'right';
                                        doc.content[0].table.body[i][14].alignment = 'right';
                                    };
                                }
                            }]
                    });
            }
        }

    </script>

    <style type="text/css">
        div.dataTables_wrapper {
            margin: 0 auto;
        }

        .dataTables_scroll {
            overflow: auto;
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
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromDate" runat="server" Text="From Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromDate" runat="server" onfocus="this.blur();" CssClass="fromdate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtToDate" runat="server" onfocus="this.blur();" CssClass="todate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblEmpGroup" Text="Employee Group" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlEGroup" CssClass="ddlEGroup form-control" DataTextField="EmpGroupName" DataValueField="EmpGroupID">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4" id="divEmpCode" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" runat="server" CssClass="form-control txtCode" TabIndex="3" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Generate" TabIndex="5" CssClass="btn btn-default" OnClientClick="return _btnCheck();" OnClick="btnGenerat_Click" />
                        <input type="hidden" class="hdnUserName" id="hdnUserName" runat="server" />
                    </div>
                </div>
            </div>
        </div>
        <div class="row">
            <div class="col-lg-12">
                <asp:GridView ID="gvattendence" runat="server" CssClass="gvattendence table nowrap" Style="font-size: 11px;" CellSpacing="0" Width="100%" OnPreRender="gvattendence_Prerender" AutoGenerateColumns="False"
                    HeaderStyle-CssClass=" table-header-gradient" FooterStyle-CssClass=" table-header-gradient" EmptyDataText="No data found. ">
                    <Columns>
                        <asp:TemplateField HeaderText="Code" HeaderStyle-Width="300px">
                            <ItemTemplate>
                                <a id="OrderMap" style="cursor: pointer" class="OrderMap"><%# Eval("Employeecode") %> - <%# Eval("Employeename") %></a>
                                <asp:Label ID="lblEntryID" Text='<%# Eval("EntryID") %>' runat="server" Visible="false"></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField HeaderText="Day" DataField="Day" HeaderStyle-Width="60px" ItemStyle-HorizontalAlign="Left" />
                        <asp:BoundField HeaderText="In Date" DataField="InDate" DataFormatString="{0:dd/MM/yyyy}" HeaderStyle-Width="60px" ItemStyle-HorizontalAlign="Center" />
                        <asp:BoundField HeaderText="In Time" DataField="InTime" HeaderStyle-Width="60px" ItemStyle-HorizontalAlign="Right" />
                        <asp:BoundField HeaderText="Out Date" DataField="OutDate" DataFormatString="{0:dd/MM/yyyy}" HeaderStyle-Width="60px" ItemStyle-HorizontalAlign="Center" />
                        <asp:BoundField HeaderText="Out Time" DataField="OutTime" HeaderStyle-Width="60px" ItemStyle-HorizontalAlign="Right" />
                        <asp:BoundField HeaderText="In City Flag" DataField="IncityFlag" HeaderStyle-Width="60px" />
                        <asp:BoundField HeaderText="Out City Flag" DataField="outcityFlag" HeaderStyle-Width="60px" />
                        <asp:BoundField HeaderText="In City Name" DataField="incityname" HeaderStyle-Width="60px" />
                        <asp:BoundField HeaderText="Out City Name" DataField="outcityname" HeaderStyle-Width="60px" />
                        <asp:BoundField HeaderText="Working Hours" DataField="Hours" HeaderStyle-Width="40px" ItemStyle-HorizontalAlign="Right" />
                        <asp:BoundField HeaderText="Visited Cities" DataField="LastVisitedCity" HeaderStyle-Width="100px" />
                        <asp:BoundField HeaderText="ProdCall" DataField="ProdCall" HeaderStyle-Width="50px" ItemStyle-HorizontalAlign="Right" />
                        <asp:BoundField HeaderText="Non ProdCall" DataField="NonProdCall" HeaderStyle-Width="50px" ItemStyle-HorizontalAlign="Right" />
                        <asp:BoundField HeaderText="Nos. Of line" DataField="NoOfLines" HeaderStyle-Width="50px" ItemStyle-HorizontalAlign="Right" />
                        <asp:TemplateField HeaderText="View More" HeaderStyle-Width="100px">
                            <ItemTemplate>
                                <asp:LinkButton ID="lnkViewDetail" runat="server" Text="View More" OnClientClick='<%# String.Format("ViewDetails({0}); return false;", Eval("EntryID")) %>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <HeaderStyle CssClass=" table-header-gradient"></HeaderStyle>
                </asp:GridView>
            </div>
        </div>
    </div>
</asp:Content>

