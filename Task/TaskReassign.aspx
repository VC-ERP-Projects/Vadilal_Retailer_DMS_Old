<%@ Page Language="C#" AutoEventWireup="true" CodeFile="TaskReassign.aspx.cs" Inherits="Task_TaskReassign" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../Scripts/ui/css/smoothness/jquery-ui-1.10.3.custom.css" rel="stylesheet" type="text/css" />
    <link href="../Scripts/BootStrapCSS/bootstrap-theme.css" rel="stylesheet" type="text/css" />
    <link href="../Scripts/BootStrapCSS/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <link href="../Scripts/BootStrapCSS/index.css" rel="stylesheet" type="text/css" />
    <link href="../Scripts/datatable_new/jquery.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/datatable_new/buttons.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/model/basic.css" rel="stylesheet" />

    <script src="../Scripts/jquery-1.9.1.js" type="text/javascript"></script>
    <script src="../Scripts/ui/js/jquery-ui-1.10.3.custom.js" type="text/javascript"></script>
    <script src="../Scripts/Bootstrap/bootstrap.js" type="text/javascript"></script>
    <script src="../Scripts/model/jquery.simplemodal-1.4.4.js" type="text/javascript"></script>
    <script src="../Scripts/timepick/jquery.plugin.min.js"></script>
    <script src="../Scripts/timepick/jquery.timeentry.min.js"></script>
    <script src="../Scripts/datatable_new/jquery.dataTables.min.js"></script>
    <script src="../Scripts/datatable_new/dataTables.buttons.min.js"></script>
    <script src="../Scripts/datatable_new/buttons.html5.min.js"></script>
    <script src="../Scripts/datatable_new/pdfmake.min.js"></script>
    <script src="../Scripts/datatable_new/vfs_fonts.js"></script>
    <script src="../Scripts/datatable_new/jszip.min.js"></script>
    <script src="../Scripts/model/jquery.simplemodal-1.4.4.js" type="text/javascript"></script>
    <script type="text/javascript">
        var availableEmployee = [];

        $(document).ready(function () {
            var dt = new Date();
            var date = String(dt.getDate()).padStart(2, '0') + '/' + String(dt.getMonth() + 1).padStart(2, '0') + '/' + dt.getFullYear();
            var time = '';
            if (date == $('.date').val())
                time = dt.getHours() + ":" + dt.getMinutes();

            $('.txtTime').timeEntry({ show24Hours: true, spinnerImage: '', minTime: time });


            $('.date').datepicker({
                numberOfMonths: 1,
                dateFormat: 'dd/mm/yy',
                changeMonth: true,
                changeYear: true,
                minDate: new Date(),
                onClose: function (dateText, inst) {
                    $(this).datepicker('setDate', new Date(inst.selectedYear, inst.selectedMonth, inst.selectedDay));
                    time = '';
                    if (date == $('.date').val()) {
                        time = ("0" + dt.getHours()).slice(-2) + ":" + ("0" + dt.getMinutes()).slice(-2);
                        $('.txtTime').val(time);
                    }
                    $('.txtTime').timeEntry('destroy');
                    $('.txtTime').timeEntry({ show24Hours: true, spinnerImage: '', minTime: time });

                }

            });

            $.ajax({
                url: 'TaskReassign.aspx/LoadData',
                type: 'POST',
                dataType: 'json',
                async: false,
                contentType: 'application/json; charset=utf-8',
                success: function (result) {

                    if (result.d == "") {
                        event.preventDefault();
                        return false;
                    }
                    else if (result.d[0].indexOf("ERROR#") >= 0) {
                        var ErrorMsg = result.d[0].split('#')[1].trim();
                        ModelMsg(ErrorMsg, 3);
                        event.preventDefault();
                        return false;
                    }
                    else {

                        var Employee = result.d[0];
                        availableEmployee = [];
                        for (var i = 0; i < Employee.length; i++) {
                            availableEmployee.push(Employee[i]);
                        }
                        $(".AutoEmp").autocomplete({
                            source: availableEmployee,
                            minLength: 0,
                            scroll: true
                        });
                    }
                }
            });
            if ($('.gvData thead tr').length > 0) {

                var aryJSONColTable = [];

                aryJSONColTable.push({ "width": "40px", "aTargets": 0 });
                aryJSONColTable.push({ "width": "30px", "aTargets": 1 });
                aryJSONColTable.push({ "width": "100px", "aTargets": 2 });
                aryJSONColTable.push({ "width": "40px", "aTargets": 3 });
                aryJSONColTable.push({ "width": "55px", "aTargets": 4 });
                aryJSONColTable.push({ "width": "80px", "aTargets": 5 });
                aryJSONColTable.push({ "width": "40px", "aTargets": 6 });
                aryJSONColTable.push({ "width": "240px", "aTargets": 7 });
                aryJSONColTable.push({ "width": "60px", "aTargets": 8 });
                aryJSONColTable.push({ "width": "50px", "aTargets": 9 });
                aryJSONColTable.push({ "width": "40px", "aTargets": 10 });

                $(".gvData").DataTable({
                    'bSort': false,
                    scrollCollapse: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    scrollY: '55vh',
                    scrollX: true,
                    responsive: true,
                    "bPaginate": true,
                    "bLengthChange": false,
                    pageLength: 10,
                    "aoColumnDefs": aryJSONColTable
                });
            }

            if ($('.gvHistory tbody tr').length > 0) {

                var aryJSONColTable = [];

                aryJSONColTable.push({ "width": "2px", "aTargets": 0 });
                aryJSONColTable.push({ "width": "90px", "aTargets": 1 });
                aryJSONColTable.push({ "width": "90px", "aTargets": 2 });
                aryJSONColTable.push({ "width": "180px", "aTargets": 3 });
                aryJSONColTable.push({ "width": "180px", "aTargets": 4 });
                aryJSONColTable.push({ "width": "70px", "aTargets": 5 });
                aryJSONColTable.push({ "width": "280px", "aTargets": 6 });

                $(".gvHistory").DataTable({
                    'bSort': false,
                    scrollCollapse: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    scrollY: '48vh',
                    scrollX: true,
                    responsive: true,
                    dom: 'Bfrtip',
                    "bPaginate": true,
                    "bLengthChange": false,
                    pageLength: 10,
                    "aoColumnDefs": aryJSONColTable,
                    buttons: [

                       {
                           extend: 'csv',
                           footer: true,
                           filename: 'Assignment History',
                           customize: function (csv) {
                               var data = 'Assignment History' + '\n';
                               data += 'Task Type,' + ($('.txtType').val()) + '\n';
                               data += 'Task No,' + ($('.txtTaskNo').val()) + '\n';
                               data += 'Task Name (Subject),' + ($('.txtName').val()) + '\n';

                               return data + csv;
                           },
                           exportOptions: {
                               columns: "thead th:not(.hideColumn)",
                               format: {
                                   body: function (data, row, column, node) {
                                       //check if type is input using jquery
                                       return (data == "&nbsp;" || data == "") ? " " : data;
                                   },
                                   footer: function (data, row, column, node) {
                                       //check if type is input using jquery
                                       return (data == "&nbsp;" || data == "") ? " " : data;
                                   }
                               }
                           }
                       },
                       {
                           extend: 'excel', footer: true,
                           filename: 'Assignment History',
                           exportOptions: {
                               columns: "thead th:not(.hideColumn)"
                           },
                           customize: function (xlsx) {

                               sheet = ExportXLS(xlsx, 5);

                               var r0 = Addrow(1, [{ key: 'A', value: 'Assignment History ' }]);
                               var r1 = Addrow(2, [{ key: 'A', value: 'Task Type' }, { key: 'B', value: $('.txtType').val() }]);
                               var r2 = Addrow(3, [{ key: 'A', value: 'Task No' }, { key: 'B', value: ($('.txtTaskNo').val()) }]);
                               var r3 = Addrow(4, [{ key: 'A', value: 'Task Name (Subject)' }, { key: 'B', value: $('.txtName').val() }]);
                               sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r3 + sheet.childNodes[0].childNodes[1].innerHTML;
                           }
                       }, {
                           extend: 'pdfHtml5',
                           orientation: 'landscape', //portrait
                           pageSize: 'A4', //A3 , A5 , A6 , legal , letter
                           title: 'Assignment History',
                           footer: 'false',
                           exportOptions: {
                               columns: "thead th:not(.hideColumn)",
                               search: 'applied',
                               order: 'applied'
                           },
                           customize: function (doc) {
                               doc.content.splice(0, 1);
                               var now = new Date();
                               Date.prototype.today = function () {
                                   return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
                               }
                               var jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: true });
                               doc.pageMargins = [20, 70, 20, 30];
                               doc.defaultStyle.fontSize = 7;
                               doc.styles.tableHeader.fontSize = 7;
                               doc.styles.tableFooter.fontSize = 7;
                               doc['content']['0'].table.widths = ['5%', '10%', '10%', '20%', '25%', '10%', '20%'];
                               doc['header'] = (function () {
                                   return {
                                       columns: [
                                           {
                                               alignment: 'left',
                                               italics: false,
                                               text: [{ text: 'Task Type                     : ' + ($('.txtType').val()) + '\n' },
                                                      { text: 'Task No                        : ' + ($('.txtTaskNo').val()) + '\n' },
                                                      { text: 'Task Name (Subject) : ' + ($('.txtName').val()) + '\n' },
                                               ],

                                               fontSize: 10,
                                               height: 500,
                                           },
                                           {
                                               alignment: 'right',
                                               fontSize: 14,
                                               text: 'Assignment History',
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
                               //objLayout['hLineWidth'] = function (i) { return .5; };
                               //objLayout['vLineWidth'] = function (i) { return .5; };
                               objLayout['hLineColor'] = function (i) { return '#000'; };
                               objLayout['vLineColor'] = function (i) { return '#000'; };
                               //objLayout['paddingLeft'] = function (i) { return 4; };
                               //objLayout['paddingRight'] = function (i) { return 4; };
                               doc.content[0].layout = objLayout;
                           }
                       }],
                });
            }
        });
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

        function ModelMsg(Text, ECode) {
            if (ECode == undefined)
                ECode = "1";
            $.modal(Text, ECode);
        }
    </script>
    <style>
        .ui-menu-item {
            font-size: 12px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:HiddenField runat="server" ID="hdnTaskID" />
        <div runat="server" id="divTaskAssign" visible="false">
            <div class="container-fluid">
                <div class="panel-heading">
                    <h3 class="panel-title"><b>Task Assignment </b></h3>
                </div>
                <div class="panel panel-default">
                    <div class="panel-body">
                        <div class="row _masterForm">
                            <div class="col-lg-4" id="divEmpCode" runat="server">
                                <div class="input-group form-group">
                                    <asp:Label Text="Assign Employee" runat="server" CssClass="input-group-addon" />
                                    <asp:TextBox ID="AutoEmp" runat="server" CssClass="AutoEmp form-control txtCode" Style="background-color: rgb(250, 255, 189);" OnTextChanged="ddlEmpList_SelectedIndexChanged"></asp:TextBox>
                                </div>
                            </div>
                            <div class="col-lg-4">
                                <div class="input-group form-group">
                                    <asp:Label Text="Date" runat="server" CssClass="input-group-addon" />
                                    <asp:TextBox runat="server" ID="txtDate" CssClass="date form-control" TabIndex="2" />
                                </div>
                            </div>
                            <div class="col-lg-4">
                                <div class="input-group form-group">
                                    <asp:Label Text="Time" runat="server" CssClass="input-group-addon" />
                                    <asp:TextBox runat="server" ID="txtTime" CssClass="txtTime form-control" TabIndex="3" />
                                </div>
                            </div>
                            <div class="col-lg-4" id="divReason" runat="server">
                                <div class="input-group form-group">
                                    <asp:Label Text="ReAssign Reason" runat="server" CssClass="input-group-addon" />
                                    <asp:DropDownList runat="server" TabIndex="1" ID="ddlReason" CssClass="ddlReason form-control">
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="col-lg-6">
                                <div class="input-group form-group">
                                    <asp:Label Text="Remarks" runat="server" CssClass="input-group-addon" />
                                    <asp:TextBox ID="txtRemarks" runat="server" TabIndex="5" CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <div class="col-lg-2">
                                <div class="input-group form-group">
                                    <asp:Button ID="btnAssign" runat="server" Text="Assignment" TabIndex="4" CssClass="btn btn-default" UseSubmitBehavior="false" OnClientClick="this.disabled='true';" OnClick="btnAssign_Click" />
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-lg-12">
                                <asp:GridView ID="gvData" runat="server" CssClass="gvData table table-bordered" Style="width: 100%; font-size: 11px;"
                                    OnPreRender="gvData_PreRender" ShowHeader="true" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass="table-header-gradient"
                                    EmptyDataText="No data found. ">
                                </asp:GridView>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div runat="server" id="divTaskHistory" visible="false">
            <div class="container-fluid">
                <div class="panel-heading">
                    <h3 class="panel-title"><b>Assignment History</b></h3>
                </div>
                <div class="panel panel-default">
                    <div class="panel-body">
                        <div class="row _masterForm">
                            <div class="col-lg-4">
                                <div class="input-group form-group">
                                    <asp:Label Text="Task Type" runat="server" CssClass="input-group-addon" />
                                    <asp:TextBox runat="server" ID="txtType" CssClass="txtType date form-control" Enabled="false" />
                                </div>
                            </div>
                            <div class="col-lg-3">
                                <div class="input-group form-group">
                                    <asp:Label Text="Task No" runat="server" CssClass="input-group-addon" />
                                    <asp:TextBox runat="server" ID="txtTaskNo" CssClass="txtTaskNo form-control" Enabled="false" />
                                </div>
                            </div>
                            <div class="col-lg-12">
                                <div class="input-group form-group">
                                    <asp:Label Text="Task Name (Subject)" runat="server" CssClass="input-group-addon" />
                                    <asp:TextBox runat="server" ID="txtName" CssClass="txtName form-control" Enabled="false" />
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-lg-12">
                                <asp:GridView ID="gvHistory" runat="server" AutoGenerateColumns="false" CssClass="gvHistory table table-bordered nowrap" Style="width: 100%; font-size: 11px;"
                                    OnPreRender="gvHistory_PreRender" ShowHeader="true" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass="table-header-gradient"
                                    EmptyDataText="No data found. ">
                                    <Columns>
                                        <asp:TemplateField HeaderText="Level">
                                            <ItemTemplate>
                                                <%# Eval("Level") %>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Task Entry Date">
                                            <ItemTemplate>
                                                <%# Eval("Task Entry Date") %>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Source">
                                            <ItemTemplate>
                                                <%# Eval("Source") %>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="From Emp">
                                            <ItemTemplate>
                                                <%# Eval("From Emp") %>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="To Emp">
                                            <ItemTemplate>
                                                <%# Eval("To Emp") %>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Status">
                                            <ItemTemplate>
                                                <%# Eval("Status") %>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Remarks">
                                            <ItemTemplate>
                                                <%# Eval("Remarks") %>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Image1" HeaderStyle-CssClass="hideColumn">
                                            <ItemTemplate>
                                                <a target="_blank" href='<%#(Eval("Image1").ToString()=="" ? "" : Eval("Image1"))%>'><%#(Eval("Image1").ToString()=="" ? "" : "Image1")%></a>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Image2" HeaderStyle-CssClass="hideColumn">
                                            <ItemTemplate>
                                                <a target="_blank" href='<%#(Eval("Image2").ToString()=="" ? "" : Eval("Image2"))%>'><%#(Eval("Image2").ToString()=="" ? "" : "Image2")%></a>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Image3" HeaderStyle-CssClass="hideColumn">
                                            <ItemTemplate>
                                                <a target="_blank" href='<%#(Eval("Image3").ToString()=="" ? "" : Eval("Image3"))%>'><%#(Eval("Image3").ToString()=="" ? "" : "Image3")%></a>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Image4" HeaderStyle-CssClass="hideColumn">
                                            <ItemTemplate>
                                                <a target="_blank" href='<%#(Eval("Image4").ToString()=="" ? "" : Eval("Image4"))%>'><%#(Eval("Image4").ToString()=="" ? "" : "Image4")%></a>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
