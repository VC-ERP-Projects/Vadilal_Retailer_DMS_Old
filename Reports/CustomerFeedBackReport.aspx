<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="CustomerFeedBackReport.aspx.cs" Inherits="CustomerFeedBack" %>

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
        var ParentID = '<% = ParentID%>';
        var Version = 'QA';
        var imagebase64 = "";
        var LogoURL = '../Images/LOGO.png';

        $(function () {
            Reload();
            ToDataURL(LogoURL, function (dataUrl) {
                imagebase64 = dataUrl;
            })
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });
        function EndRequestHandler2(sender, args) {
            Reload();

        }

        function ToDataURL(url, callback) {
            var xhr = new XMLHttpRequest();
            xhr.onload = function () {
                var reader = new FileReader();
                reader.onloadend = function () {
                    callback(reader.result);
                }
                reader.readAsDataURL(xhr.response);
            };
            xhr.open('GET', url);
            xhr.responseType = 'blob';
            xhr.send();
        }

        function _btnCheck() {
            var IsValid = true;
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');
            IsValid = $('._masterForm').data('bootstrapValidator').isValid();
            return IsValid;
        }

        function ToDataURL(url, callback) {
            var xhr = new XMLHttpRequest();
            xhr.onload = function () {
                var reader = new FileReader();
                reader.onloadend = function () {
                    callback(reader.result);
                }
                reader.readAsDataURL(xhr.response);
            };
            xhr.open('GET', url);
            xhr.responseType = 'blob';
            xhr.send();
        }

        function Reload() {

            if ($('.GvCustData thead tr').length > 0) {
                var now = new Date();
                Date.prototype.today = function () {
                    return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
                }
                var jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: true });

                var aryJSONColTable = [];

                aryJSONColTable.push({ "width": "2%", "sClass": "dtbodyCenter", "aTargets": 0 }); ////Sr
                aryJSONColTable.push({ "width": "30%", "aTargets": 1 }); ////Dealer
                aryJSONColTable.push({ "width": "9%", "sClass": "dtbodyCenter", "aTargets": 2 });////Feedback Date/Time
                aryJSONColTable.push({ "width": "10%", "aTargets": 3 });////Question
                aryJSONColTable.push({ "width": "5%", "aTargets": 4 });////Answer  
                aryJSONColTable.push({ "width": "35%", "aTargets": 5 });////type
                aryJSONColTable.push({ "width": "5%", "aTargets": 6 });////Image1
                aryJSONColTable.push({ "width": "5%", "aTargets": 7 });////Image2
                aryJSONColTable.push({ "width": "5%", "aTargets": 8 });////Image3
                aryJSONColTable.push({ "width": "5%", "aTargets": 9 });////Image4
                aryJSONColTable.push({ "width": "5%", "aTargets": 10 });////Image4


                $(".GvCustData").DataTable({
                    bFilter: true,
                    scrollCollapse: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    destroy: true,
                    scrollY: '40vh',
                    "bInfo": false,
                    scrollX: true,
                    responsive: true,
                    dom: 'Bfrtip',
                    "bPaginate": false,
                    autowidth: true,
                    "aoColumnDefs": aryJSONColTable,
                    "order": [[0, "asc"]],
                    buttons: [
                        {
                            extend: 'csv',
                            footer: true,
                            filename: $("#lnkTitle").text(),
                            customize: function (csv) {
                                var data = 'Report Customer FeedBack - Dealer App' + '\n';
                                data += 'From Date,' + $('.fromdate').val() + ',To Date,' + $('.ToDate').val() + '\n';
                                data += 'Employee,' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val() : "All Employee") + '\n';
                                data += 'FeedBack Type,' + (($('.ddlType').length > 0 && $('.ddlType').val() != "") ? $('.ddlType option:Selected').text() : "All FeedBack Type") + '\n';
                                data += 'Created on,\'' + new Date().format('dd-MMM-yyyy HH:mm:ss') + '\n';
                                return data + csv;
                            },
                            exportOptions: {
                                columns: ':visible',//For exporting only visible columns. 
                                format: {
                                    body: function (data, row, column, node) {
                                        //check if type is input using jquery
                                        return (data == "&nbsp;" || data == "") ? " " : data;
                                        var D = data;
                                    }
                                }
                            }
                        },
                        {
                            extend: 'excel', footer: true,
                            filename: $("#lnkTitle").text(),
                            customize: function (xlsx) {

                                sheet = ExportXLS(xlsx, 3);

                                var r0 = Addrow(1, [{ key: 'A', value: 'Report Customer FeedBack - Dealer App' }]);
                                var r1 = Addrow(2, [{ key: 'A', value: 'From Month' }, { key: 'B', value: $('.fromdate').val() }, { key: 'C', value: 'To Month' }, { key: 'D', value: $('.ToDate').val() }]);
                                var r2 = Addrow(3, [{ key: 'A', value: 'Employee' }, { key: 'B', value: (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val() : "All Employee") }]);
                                var r3 = Addrow(4, [{ key: 'A', value: 'FeedBack Type' }, { key: 'B', value: (($('.ddlType').length > 0 && $('.ddlType').val() != "") ? $('.ddlType option:Selected').text() : "FeedBack Type") }]);
                                var r4 = Addrow(5, [{ key: 'A', value: 'Created on' }, { key: 'B', value: '\'' + (new Date().format('dd-MMM-yyyy HH:mm:ss')) }]);
                                sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r3 + r4 + sheet.childNodes[0].childNodes[1].innerHTML;
                            }
                        },
                        {
                            extend: 'pdfHtml5',
                            orientation: 'portrait', //portrait
                            pageSize: 'A4', //A3 , A5 , A6 , legal , letter
                            title: $("#lnkTitle").text(),
                            footer: 'false',
                            exportOptions: {
                                columns: ':visible',
                                search: 'applied',
                                order: 'applied'
                            },
                            customize: function (doc) {
                                doc.content.splice(0, 1);
                                var now = new Date();
                                doc.pageMargins = [20, 70, 20, 30];
                                doc.defaultStyle.fontSize = 6;
                                doc.styles.tableHeader.fontSize = 7;
                                doc.styles.tableFooter.fontSize = 7;
                                doc['header'] = (function () {
                                    return {
                                        columns: [
                                            {
                                                alignment: 'left',
                                                italics: true,
                                                text: [{ text: 'From Date : ' + $('.fromdate').val() + '\t To Date : ' + $('.ToDate').val() + "\n" },
                                                { text: 'Employee : ' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val() + "\n" : "All Employee" + "\n") },
                                                { text: 'FeedBack Type : ' + (($('.ddlType').length > 0 && $('.ddlType').val() != "") ? $('.ddlType option:Selected').text() + "\n" : "All FeedBack Type\n") },
                                                    /*{ text: 'User Name : ' + $('.hdnUserName').val() + "\n" }*/
                                                ],
                                                fontSize: 10,
                                                height: 300,
                                            },
                                            {
                                                alignment: 'right',
                                                width: 70,
                                                height: 50,
                                                image: imagebase64
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
                                                fontSize: 8,
                                                text: ['Created on: ', { text: new Date().format('dd-MMM-yyyy HH:mm:ss') }]
                                            },
                                            {
                                                alignment: 'right',
                                                fontSize: 7,
                                                text: ['User Name : ', { text: $('.hdnUserName').val() }]
                                            },
                                            {
                                                alignment: 'right',
                                                fontSize: 8,
                                                text: ['Version : ', { text: Version }]
                                            },
                                            {
                                                alignment: 'right',
                                                fontSize: 8,
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

                                for (i = 1; i < rowCount; i++) {// rows alignment setting by default left
                                    doc.content[0].table.body[i][0].alignment = 'center';
                                    doc.content[0].table.body[i][1].alignment = 'left';
                                    doc.content[0].table.body[i][2].alignment = 'center';
                                    doc.content[0].table.body[i][3].alignment = 'left';
                                    doc.content[0].table.body[i][4].alignment = 'left';
                                    doc.content[0].table.body[i][5].alignment = 'left';
                                };
                                //Header Alignment for PDF Export.
                                doc.content[0].table.body[0][0].alignment = 'center';
                                doc.content[0].table.body[0][1].alignment = 'left';
                                doc.content[0].table.body[0][2].alignment = 'center';
                                doc.content[0].table.body[0][3].alignment = 'right';
                                doc.content[0].table.body[0][4].alignment = 'left';
                                doc.content[0].table.body[0][5].alignment = 'left';
                            }
                        }
                    ],
                });
            }
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

        .dataTables_scrollBody {
            overflow-x: hidden !important;
        }

        .dataTables_scrollBody {
            overflow-x: hidden !important;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <asp:HiddenField runat="server" ID="hdnIPAdd" ClientIDMode="Static" Value="0" />
    <input type="hidden" class="hdnUserName" id="hdnUserName" runat="server" />
    <div class="panel">
        <div class="panel-body">
            <div class="row">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromDate" runat="server" Text="From Date" CssClass="lblFromDate input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromDate" runat="server" TabIndex="1" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="fromdate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate" runat="server" Text="To Date" CssClass="lblToDate input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtToDate" runat="server" TabIndex="2" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="fromdate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4" id="divEmpCode" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" onchange="ClearOtherConfig()" runat="server" CssClass="form-control txtCode" Style="background-color: rgb(250, 255, 189);" TabIndex="4"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="FeedBack Type" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList ID="ddlType" TabIndex="3" runat="server" CssClass="ddlType form-control" DataTextField="FeedbackName" AutoPostBack="true" DataValueField="FeedbackTypeID"></asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button Text="Go" ID="btnGenerat" TabIndex="5" CssClass="btn btn-default" runat="server" OnClick="btnGenerat_Click" />
                        <%--&nbsp;&nbsp;&nbsp;
                        <asp:Button Text="Cancle" ID="btncancle" TabIndex="6" CssClass="btn btn-default" runat="server" />--%>
                    </div>
                </div>
            </div>
            <%--<iframe id="ifmCustFeedBack" style="width: 100%" class="embed-responsive-item" runat="server" onload="ifmCustFeedBack_Load"></iframe>--%>
        </div>

        <div class="row">
            <div class="col-lg-12">

                <asp:GridView ID="gvgrid" runat="server" CssClass="GvCustData table nowrap" Style="font-size: 11px;" CellSpacing="0" Width="100%" OnPreRender="gvgrid_PreRender" AutoGenerateColumns="False"
                    HeaderStyle-CssClass=" table-header-gradient" FooterStyle-CssClass=" table-header-gradient" EmptyDataText="No data found. ">
                    <Columns>
                        <asp:BoundField HeaderText="Sr." DataField="Sr" HeaderStyle-Width="20px" ItemStyle-HorizontalAlign="Left" />
                        <asp:BoundField HeaderText="Dealer" DataField="Dealer" HeaderStyle-Width="100px" ItemStyle-HorizontalAlign="Left" />
                        <asp:BoundField HeaderText="Feedback Date" DataField="Feedback Date" HeaderStyle-Width="30px" ItemStyle-HorizontalAlign="Left" />
                        <asp:BoundField HeaderText="Type" DataField="Type" HeaderStyle-Width="30px" ItemStyle-HorizontalAlign="Left" />
                        <asp:BoundField HeaderText="EntryID" DataField="EntryID" HeaderStyle-Width="60px" ItemStyle-HorizontalAlign="Left" />
                        <asp:BoundField HeaderText="Question" DataField="Question" HeaderStyle-Width="60px" ItemStyle-HorizontalAlign="Left" />
                        <asp:BoundField HeaderText="Answer" DataField="Answer" HeaderStyle-Width="40px" ItemStyle-HorizontalAlign="Left" />
                        <asp:TemplateField HeaderText="Photos" HeaderStyle-Width="40px">
                            <ItemTemplate>
                                <a href='<%# (Eval("Image1").ToString() == "" ? "" : Eval("Image1").ToString()) %>' target="_blank"
                                    id="lnkPhoto1"><%# Eval("Image1").ToString() == "" ? "" : "Image" %></a>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Photos" HeaderStyle-Width="40px">
                            <ItemTemplate>
                                <a href='<%# (Eval("Image2").ToString() == "" ? "" : Eval("Image2").ToString()) %>' target="_blank"
                                    id="lnkPhoto1"><%# Eval("Image2").ToString() == "" ? "" : "Image" %></a>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Photos" HeaderStyle-Width="40px">
                            <ItemTemplate>
                                <a href='<%# (Eval("Image3").ToString() == "" ? "" : Eval("Image3").ToString()) %>' target="_blank"
                                    id="lnkPhoto1"><%# Eval("Image3").ToString() == "" ? "" : "Image" %></a>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Photos" HeaderStyle-Width="40px">
                            <ItemTemplate>
                                <a href='<%# (Eval("Image4").ToString() == "" ? "" : Eval("Image4").ToString()) %>' target="_blank"
                                    id="lnkPhoto1"><%# Eval("Image4").ToString() == "" ? "" : "Image" %></a>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <HeaderStyle CssClass=" table-header-gradient"></HeaderStyle>
                </asp:GridView>
            </div>
        </div>
</asp:Content>

