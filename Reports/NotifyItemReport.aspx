<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="NotifyItemReport.aspx.cs" Inherits="Reports_NotifyItemReport" %>

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
        var Version = 'QA';
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
        function _btnCheck() {

            var IsValid = true;

            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            IsValid = $('._masterForm').data('bootstrapValidator').isValid();
            return IsValid;
        }

        function Reload() {

            $('.frommindate').datepicker({
                numberOfMonths: 1,
                dateFormat: 'dd/mm/yy',
                changeMonth: true,
                changeYear: true,
                minDate: new Date(2017, 6, 1),
                onClose: function (dateText, inst) {
                    $(this).datepicker('setDate', new Date(inst.selectedYear, inst.selectedMonth, inst.selectedDay));
                },
                onSelect: function (selected) {
                    $('.tomindate').datepicker("option", "minDate", selected);
                }
            });

            $('.tomindate').datepicker({
                numberOfMonths: 1,
                dateFormat: 'dd/mm/yy',
                changeMonth: true,
                changeYear: true,
                //"maxDate": '<%=DateTime.Now %>',
                minDate: new Date(2017, 6, 1),
                onClose: function (dateText, inst) {
                    $(this).datepicker('setDate', new Date(inst.selectedYear, inst.selectedMonth, inst.selectedDay));
                },
                onSelect: function (selected) {
                    $('.frommindate').datepicker("option", "maxDate", selected);
                }
            });

            if ($('.gvgrid thead tr').length > 0) {
                var table = $('.gvgrid').DataTable();
                var colCount = table.columns()[0].length;
                var aryJSONColTable = [];

                aryJSONColTable.push({ "width": "10px", "aTargets": 0 });
                aryJSONColTable.push({ "width": "40px", "aTargets": 1 });
                aryJSONColTable.push({ "width": "60px", "aTargets": 2 });
                for (var i = 3; i < colCount; i++) {
                    aryJSONColTable.push({
                        "aTargets": [i],
                        "width": "100px"
                        //mRender: function (data, type, row) {
                        //    return data.split("#").join("<br/>");
                        //}
                    });

                }

                var now = new Date();
                Date.prototype.today = function () {
                    return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
                }
                var jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: true });

                $('.gvgrid').DataTable(
                    {
                        bFilter: true,
                        scrollCollapse: true,
                        "stripeClasses": ['odd-row', 'even-row'],
                        destroy: true,
                        scrollY: '40vh',
                        scrollX: true,
                        responsive: true,
                        "aaSorting": [],
                        dom: 'Bfrtip',
                        "bPaginate": false,
                        "aoColumnDefs": aryJSONColTable,
                        buttons: [{ extend: 'copy', footer: false },
                        {
                            extend: 'csv', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                            customize: function (csv) {
                                var data = 'Notify Item Report' + '\n';
                                data += 'From Date,' + $('.frommindate').val() + ',To Date,' + $('.tomindate').val() + '\n';
                                data += 'Employee,' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val() : "All Employee") + '\n';
                                data += 'Distributor Region,' + (($('.txtRegion').length > 0 && $('.txtRegion').val() != "") ? $('.txtRegion').val() : "Distributor Region") + '\n';
                                data += 'Division,' + (($('.ddlDivision').length > 0 && $('.ddlDivision').val() != "") ? $('.ddlDivision option:Selected').text() : "All Division Group") + '\n';
                                data += 'Product Group,' + (($('.ddlItemGroup').length > 0 && $('.ddlItemGroup').val() != "") ? $('.ddlItemGroup option:Selected').text() : "All Product Group") + '\n';
                                data += 'Selected Product,' + (($('.txtItem').length > 0 && $('.txtItem').val() != "") ? $('.txtItem').val() : "Selected Product") + '\n';
                                data += 'User Name,' + $('.hdnUserName').val() + '\n';
                                data += 'Created on,' + jsDate.toString() + '\n';
                                return data + csv;
                            },
                            exportOptions: {
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
                            extend: 'excel', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                            customize: function (xlsx) {
                                sheet = ExportXLS(xlsx, 8);
                                var r0 = Addrow(1, [{ key: 'A', value: 'Notify Item Report' }]);
                                var r1 = Addrow(2, [{ key: 'A', value: 'From Date' }, { key: 'B', value: $('.frommindate').val() }, { key: 'C', value: 'To Date' }, { key: 'D', value: $('.tomindate').val() }]);
                                var r2 = Addrow(3, [{ key: 'A', value: 'Employee' }, { key: 'B', value: (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val() : "All Employee") }]);
                                var r3 = Addrow(4, [{ key: 'A', value: 'Distributor Region' }, { key: 'B', value: (($('.txtRegion').length > 0 && $('.txtRegion').val() != "") ? $('.txtRegion').val() : "Distributor Region") }]);
                                var r4 = Addrow(5, [{ key: 'A', value: 'Division' }, { key: 'B', value: (($('.ddlDivision').length > 0 && $('.ddlDivision').val() != "") ? $('.ddlDivision option:Selected').text() : "All Division Group") }]);
                                var r5 = Addrow(6, [{ key: 'A', value: 'Product Group' }, { key: 'B', value: (($('.ddlItemGroup').length > 0 && $('.ddlItemGroup').val() != "") ? $('.ddlItemGroup option:Selected').text() : "All Product Group") }]);
                                var r6 = Addrow(7, [{ key: 'A', value: 'Selected Product' }, { key: 'B', value: (($('.txtItem').length > 0 && $('.txtItem').val() != "") ? $('.txtItem').val() : "Selected Product") }]);
                                var r7 = Addrow(8, [{ key: 'A', value: 'User Name' }, { key: 'B', value: $('.hdnUserName').val() }]);
                                var r8 = Addrow(9, [{ key: 'A', value: 'Created on' }, { key: 'B', value: jsDate.toString() }]);

                                sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r3 + r4 + r5 + r6 + r7 + r8 + sheet.childNodes[0].childNodes[1].innerHTML;
                            }
                        },
                        {
                            extend: 'pdfHtml5',
                            className: "buttonsToHide",
                            orientation: 'landscape', //portrait
                            pageSize: 'A4', //A3 , A5 , A6 , legal , letter
                            title: $("#lnkTitle").text(),
                            footer: 'true',
                            exportOptions: {
                                columns: ':visible',
                                search: 'applied',
                                order: 'applied'
                            },
                            customize: function (doc) {
                                doc.content.splice(0, 1);
                                doc.pageMargins = [20, 105, 20, 30];
                                doc['content']['0'].table.widths = ['5%', '5%', '20%', '5%', '5%', '5%', '15%', '5%', '5%', '5%', '20%', '5%'];
                                //doc['content']['0'].table.widths = ['1.5%', '3.5%', '3.5%', '8%', '4%', '10%', '1.7%', '5.8%', '5.8%', '3.5%', '3.5%', '10%', '3.5%', '3.5%', '3.8%', '3.3%', '3%', '4.5%', '3.8%', '5%', '5%', '5%', '5%'];
                                doc.defaultStyle.fontSize = 6;
                                doc.defaultStyle.height = '500px';
                                doc.styles.tableHeader.fontSize = 6;
                                doc.styles.tableFooter.fontSize = 6;

                                doc['header'] = (function () {
                                    return {
                                        columns: [
                                            {
                                                alignment: 'left',
                                                italics: false,
                                                text: [{ text: 'From Date : ' + $('.frommindate').val() + '\t To Date : ' + $('.tomindate').val() + "\n" },
                                                { text: 'Employee : ' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val() + "\n" : "All Employee" + "\n") },
                                                { text: 'Distributor Region : ' + (($('.txtRegion').length > 0 && $('.txtRegion').val() != "") ? $('.txtRegion').val() + "\n" : "Distributor Region" + "\n") },
                                                { text: 'Division : ' + (($('.ddlDivision').length > 0 && $('.ddlDivision').val() != "") ? $('.ddlDivision option:Selected').text() + "\n" : "All Division Group\n") },
                                                { text: 'Product Group : ' + (($('.txtGroup').length > 0 && $('.txtGroup').val() != "") ? $('.txtGroup').val() + "\n" : "Product Group" + "\n") },
                                                { text: 'Selected Product : ' + (($('.txtItem').length > 0 && $('.txtItem').val() != "") ? $('.txtItem').val() + "\n" : "Selected Product" + "\n") },
                                                { text: 'User Name : ' + $('.hdnUserName').val() + "\n" }],
                                                fontSize: 10,
                                                height: 900,
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
                                                text: ['Created on: ', { text: jsDate.toString() }]
                                            },
                                            {
                                                alignment: 'right',
                                                fontSize: 8,
                                                text: ['User Name : ', { text: $('.hdnUserName').val() }]
                                            },
                                            {
                                                alignment: 'right',
                                                fontSize: 8,
                                                text: ['Version : ', { text: Version }]
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
                                objLayout['paddingLeft'] = function (i) { return 2; };
                                objLayout['paddingRight'] = function (i) { return 2; };
                                doc.content[0].layout = objLayout;

                                //var rowCount = doc.content[0].table.body.length;
                                //for (i = 1; i < rowCount; i++) {
                                //    for (var j = 4; j < colCount; j++) {
                                //        doc.content[0].table.body[i][j].alignment = 'right';
                                //    }
                                //};
                            }
                        }]
                    }
                );

            }
        }



        function autoCompleteState_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey(EmpID);
        }
        function autoCompleteItemName_OnClientPopulating(sender, args) {
            var GroupId = $('.ddlItemGroup').val();
            sender.set_contextKey(GroupId + "-" + $('.ddlDivision').val());
        }


        function _btnCheck() {
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');
            return $('._masterForm').data('bootstrapValidator').isValid();
        }
        function GroupChangeEvent() {
            $('.txtItem').val('');
        }


    </script>

    <style>
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
    <input type="hidden" class="hdnUserName" id="hdnUserName" runat="server" />
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromDate" runat="server" Text="From Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromDate" runat="server" TabIndex="1" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="frommindate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtToDate" runat="server" TabIndex="2" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="tomindate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4" id="divEmpCode" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" runat="server" CssClass="form-control txtCode" Style="background-color: rgb(250, 255, 189);" TabIndex="3"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4" id="divRegion" runat="server">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Distributor Region</label>
                        <asp:TextBox ID="txtRegion" CssClass="txtRegion form-control" runat="server" Style="background-color: rgb(250, 255, 189);" autocomplete="off" TabIndex="4"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender1" runat="server" ServiceMethod="SaleSchmeGetDistributorRegionCurrHierarchy"
                            ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" OnClientPopulating="autoCompleteState_OnClientPopulating"
                            TargetControlID="txtRegion" UseContextKey="True">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Division" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList runat="server" ID="ddlDivision" TabIndex="5" AutoPostBack="true" OnSelectedIndexChanged="ddlDivision_SelectedIndexChanged" CssClass="ddlDivision form-control" DataTextField="DivisionName" DataValueField="DivisionlID">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblGroupName" runat="server" Text='Product Group' CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlItemGroup" runat="server" CssClass="ddlItemGroup form-control" onChange="GroupChangeEvent();" TabIndex="11" DataTextField="ItemGroupName" DataValueField="ItemGroupID">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Selected Product" ID="lblItem" runat="server" CssClass="input-group-addon" />
                        <asp:TextBox runat="server" ID="txtItem" CssClass="form-control txtItem" Style="background-color: rgb(250, 255, 189);" autocomplete="off" TabIndex="7" />
                        <asp:AutoCompleteExtender ID="acetxtItemName" runat="server" ServicePath="~/WebService.asmx"
                            EnableCaching="false" UseContextKey="true" ServiceMethod="GetMaterial" MinimumPrefixLength="1" CompletionInterval="10"
                            OnClientPopulating="autoCompleteItemName_OnClientPopulating" CompletionSetCount="1" TargetControlID="txtItem" OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Generate" TabIndex="9" CssClass="btn btn-default" OnClientClick="return _btnCheck();" OnClick="btnGenerat_Click" />
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-lg-12">
                    <%-- <asp:GridView ID="gvgrid" runat="server" CssClass="gvgrid table" Width="100%" Style="font-size: 11px;" AutoGenerateColumns="true"
                        OnPreRender="gvgrid_PreRender" ShowHeader="true" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass=" table-header-gradient"
                        EmptyDataText="No data found. ">--%>
                    <asp:GridView ID="gvgrid" runat="server" CssClass="gvgrid table nowrap" Style="font-size: 11px;" CellSpacing="0" Width="100%" OnPreRender="gvgrid_PreRender" AutoGenerateColumns="False"
                        HeaderStyle-CssClass=" table-header-gradient" FooterStyle-CssClass=" table-header-gradient" EmptyDataText="No data found. ">
                        <Columns>
                            <%-- <asp:TemplateField HeaderText="Code" HeaderStyle-Width="300px">
                            <ItemTemplate>
                                <a id="OrderMap" style="cursor: pointer" class="OrderMap"><%# Eval("Employeecode") %> - <%# Eval("Employeename") %></a>
                                <asp:Label ID="lblEntryID" Text='<%# Eval("EntryID") %>' runat="server" Visible="false"></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>--%>
                            <asp:BoundField HeaderText="Sr." DataField="Sr." HeaderStyle-Width="65px" ItemStyle-HorizontalAlign="Left" />
                            <asp:BoundField HeaderText="Dealer Code" DataField="Dealer Code" HeaderStyle-Width="65px" ItemStyle-HorizontalAlign="Left" />
                            <%-- <asp:BoundField HeaderText="Dealer Code" DataField="Dealer Code" DataFormatString="{0:dd/MM/yyyy}" HeaderStyle-Width="60px" ItemStyle-HorizontalAlign="Center" />--%>
                            <asp:BoundField HeaderText="Dealer Name" DataField="Dealer Name" HeaderStyle-Width="60px" ItemStyle-HorizontalAlign="Left" />
                            <%-- <asp:BoundField HeaderText="City" DataField="OutDate" DataFormatString="{0:dd/MM/yyyy}" HeaderStyle-Width="60px" ItemStyle-HorizontalAlign="Center" />--%>
                            <asp:BoundField HeaderText="City" DataField="City" HeaderStyle-Width="30px" ItemStyle-HorizontalAlign="Left" />
                            <asp:BoundField HeaderText="Region" DataField="Region" HeaderStyle-Width="30px" ItemStyle-HorizontalAlign="Left" />
                            <asp:BoundField HeaderText="Distributor Code" DataField="Distributor Code" HeaderStyle-Width="60px" ItemStyle-HorizontalAlign="Left" />
                            <asp:BoundField HeaderText="Distributor Name" DataField="Distributor Name" HeaderStyle-Width="60px" ItemStyle-HorizontalAlign="Left" />
                            <asp:BoundField HeaderText="Distributor City" DataField="Distributor City" HeaderStyle-Width="40px" ItemStyle-HorizontalAlign="Left" />
                            <asp:BoundField HeaderText="Distributor Region" DataField="Distributor Region" HeaderStyle-Width="30px" ItemStyle-HorizontalAlign="Left" />
                            <asp:BoundField HeaderText="Product Code" DataField="Product Code" HeaderStyle-Width="40px" ItemStyle-HorizontalAlign="Left" />
                            <asp:BoundField HeaderText="Product Name" DataField="Product Name" HeaderStyle-Width="40px" ItemStyle-HorizontalAlign="Left" />
                            <asp:BoundField HeaderText="NotifyDate" DataField="NotifyDate" HeaderStyle-Width="30px" ItemStyle-HorizontalAlign="Left" />
                            <%-- <asp:BoundField HeaderText="Nos. Of line" DataField="NoOfLines" HeaderStyle-Width="50px" ItemStyle-HorizontalAlign="Right" />--%>
                        </Columns>
                        <HeaderStyle CssClass=" table-header-gradient"></HeaderStyle>
                    </asp:GridView>
                </div>
            </div>
        </div>
</asp:Content>

