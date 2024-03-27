<%@ Page Title="" Language="C#" MasterPageFile="~/ReportMaster.master" AutoEventWireup="true" CodeFile="AssetScanNotScanList.aspx.cs" Inherits="Reports_AssetScanNotScanList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">
        var Version = '<% = Version%>';
        <%--var ParentID = <% = ParentID%>;--%>
        //---Start Current Hirarchy
        function acetxtDealerCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            sender.set_contextKey("0-0-0-0-0-" + EmpID);
        }

        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            sender.set_contextKey("0-0-0-0-" + EmpID);
        }

        function autoCompleteSSDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            sender.set_contextKey("0-0-0-" + EmpID);
        }

        function autoCompletePlant_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey("0-0-" + EmpID);
        }
        //---End Current Hirarchy

        //---Start all data Current Hirarchy for Asset At presently
        function acetxtAssetAtDealerCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            sender.set_contextKey("0-0-0-0-0-0");
        }

        function autoCompleteAssetAtDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            sender.set_contextKey("0-0-0-0-0");
        }

        function autoCompleteAssetAtSSDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            sender.set_contextKey("0-0-0-0");
        }

        function autoCompleteAssetAtPlant_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey("0-0-0");
        }
        //---End all data Current Hirarchy for Asset At presently

        $(function () {

            window.jsPDF = window.jspdf.jsPDF;
            applyPlugin(window.jsPDF);

            loadPanel = $(".loadpanel").dxLoadPanel({
                shadingColor: "rgba(0,0,0,0.4)",
                visible: false,
                showIndicator: true,
                showPane: true,
                shading: true,
                closeOnOutsideClick: false,
            }).dxLoadPanel("instance");
            Reload();
            TabSequence();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });
        function TabSequence() {
            var tabindex = 1;
            $('.dx-texteditor-input').each(function () {
                if (this.type != "hidden") {
                    var $input = $(this);
                    $input.attr("tabindex", tabindex);
                    tabindex++;
                }
            });
        }
        function EndRequestHandler2(sender, args) {
            Reload();
        }
        function Reload() {
            ChangeSearch();
            ChangeReport();
            ChangeAssetAtReport();
            var date = new Date();
            const dxFromDate = $("#txtdxFromDate").dxDateBox({
                placeholder: "dd/MM/yyyy",
                showClearButton: false,
                useMaskBehavior: true,
                displayFormat: "dd/MM/yyyy",
                type: "date",
                value: date,
                onValueChanged: function (e) {
                    dxToDate.option("min", e.value);
                    TabSequence();
                }
            }).dxDateBox("instance");
            const dxToDate = $("#txtdxToDate").dxDateBox({
                placeholder: "dd/MM/yyyy",
                showClearButton: false,
                useMaskBehavior: true,
                displayFormat: "dd/MM/yyyy",
                type: "date",
                value: date,
                onValueChanged: function (e) {
                    dxFromDate.option("max", e.value);
                    TabSequence();
                }
            }).dxDateBox("instance");

        }
        function ExportToExcelLabel() {
            $('.dx-datagrid-export-button .dx-button-content .dx-icon-export-excel-button').each(function () {
                $(this).after($('<span class="dx-button-text">').text("Export To Excel"));
            });
            $('.dx-datagrid-export-button').addClass('dx-button-has-text');
        }
        function convertDateStringToDate(dateStr) {
            let months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
            let date = new Date(dateStr);
            var day = date.getDate();

            let str = (('' + day).length < 2 ? '0' : '') + day + '-' + months[date.getMonth()] + '-' + date.getFullYear().toString().substr(-2)
            return str;
        }
        var collapsed = false;

        function load(id) {
            if (id == 0) {
                loadPanel.show();
            }
            else {
                loadPanel.hide();
            }
        }
        function FillGrid(Data) {
            var dataGrid = $("#gridContainer").dxDataGrid({
                dataSource: Data,
                paging: {
                    enabled: false
                },
                scrolling: {
                    rowRenderingMode: 'virtual',
                },
                pager: {
                    visible: true,
                    allowedPageSizes: ['all'],
                    showPageSizeSelector: false,
                    showInfo: true,
                    showNavigationButtons: false
                },
                columnAutoWidth: true,
                remoteOperations: false,
                allowSorting: false,
                searchPanel: {
                    visible: true,
                    highlightCaseSensitive: true
                },
                groupPanel: { visible: false },
                filterRow: { visible: false, applyFilter: "auto" },
                grouping: {
                    autoExpandAll: false
                },
                showBorders: true,
                headerFilter: {
                    visible: false,
                    allowSearch: true
                },
                filterPanel: { visible: false },
                filterBuilderPopup: {
                    position: { of: window, at: "top", my: "top", offset: { y: 10 } },
                },
                allowColumnReordering: false,
                rowAlternationEnabled: true,
                showBorders: true,
                columnChooser: {
                    enabled: true
                },
                export: {
                    enabled: true
                },
                groupPanel: { visible: false },
                columnChooser: {
                    enabled: false,
                },
                sorting: false,
                onExporting: function (e) {
                    var workbook = new ExcelJS.Workbook();
                    var worksheet = workbook.addWorksheet(' ');
                    var rowCount;
                    if ($('.ddlSearchFor option:selected').val() == "0" && $('.ddlOption').val() == "1" && ($('.ddlAssetPresent option:selected').val() == "0" || $('.ddlAssetPresent option:selected').val() == "7" || $('.ddlAssetPresent option:selected').val() == "8")) { rowCount = 15; }
                    else if ($('.ddlSearchFor option:selected').val() == "0" && $('.ddlOption').val() == "1" && $('.ddlAssetPresent option:selected').val() != "0") { rowCount = 16; }
                    else if ($('.ddlSearchFor option:selected').val() == "0" && $('.ddlOption').val() == "2") { rowCount = 11; }
                    else if (($('.ddlSearchFor option:selected').val() == "1" || $('.ddlSearchFor option:selected').val() == "2") && $('.ddlOption').val() == "1" && ($('.ddlAssetPresent option:selected').val() == "0" || $('.ddlAssetPresent option:selected').val() == "7" || $('.ddlAssetPresent option:selected').val() == "8")) { rowCount = 12; }
                    else if (($('.ddlSearchFor option:selected').val() == "1" || $('.ddlSearchFor option:selected').val() == "2") && $('.ddlOption').val() == "1" && $('.ddlAssetPresent option:selected').val() != "0") { rowCount = 13; }
                    else if (($('.ddlSearchFor option:selected').val() == "1" || $('.ddlSearchFor option:selected').val() == "2") && $('.ddlOption').val() == "2") { rowCount = 10; }
                    else if (($('.ddlSearchFor option:selected').val() == "3" || $('.ddlSearchFor option:selected').val() == "4") && $('.ddlOption').val() == "1") { rowCount = 10; }
                    else if (($('.ddlSearchFor option:selected').val() == "3" || $('.ddlSearchFor option:selected').val() == "4") && $('.ddlOption').val() == "2") { rowCount = 9; }
                    DevExpress.excelExporter.exportDataGrid({
                        component: e.component,
                        worksheet: worksheet,
                        keepColumnWidths: false,
                        topLeftCell: { row: rowCount, column: 1 },
                        customizeCell: function (options) {
                            var gridCell = options.gridCell;
                            var excelCell = options.excelCell;
                            //if (gridCell.rowType === "header") {
                            //    gridCell.horizontalAlignment = 'left';
                            //}
                            //if (gridCell.rowType === "data") {
                            excelCell.alignment = { horizontal: 'left' };
                            if (gridCell.column.dataField === 'Sr' || gridCell.column.dataField === 'SRNO' || gridCell.column.dataField === 'LGMDate' || gridCell.column.dataField === 'ScanDateTime') {
                                excelCell.alignment = { horizontal: 'center' };
                            }
                            if (gridCell.column.dataField === 'Lat' || gridCell.column.dataField === 'Long') {
                                excelCell.alignment = { horizontal: 'right' };
                            }
                            //}
                        }
                    }).then(function (cellRange) {
                        // header
                        var AssetAtCustLabel = $('.ddlOption').val() == "1" && $('.ddlAssetPresent').val() == "2" ? "Asset Presently At Distributor : " :
                            $('.ddlOption').val() == "1" && $('.ddlAssetPresent').val() == "3" ? "Asset Presently At Dealer : " :
                            $('.ddlOption').val() == "1" && $('.ddlAssetPresent').val() == "4" ? "Asset Presently At Super Stockist : " :
                            $('.ddlOption').val() == "1" && $('.ddlAssetPresent').val() == "5" ? "Asset Presently At Plant : " :
                            $('.ddlOption').val() == "1" && $('.ddlAssetPresent').val() == "6" ? "Asset Presently At Storage Location : " : "";

                        var AssetAtCustText = $('.ddlOption').val() == "1" && $('.ddlAssetPresent').val() == "2" ? ($('.txtAssetDistCode').val() != '' ? $('.txtAssetDistCode').val().split('-')[0].trim() + " # " + $('.txtAssetDistCode').val().split('-')[1].trim() : 'All') :
                        $('.ddlOption').val() == "1" && $('.ddlAssetPresent').val() == "3" ? ($('.txtAssetDealerCode').val() != '' ? $('.txtAssetDealerCode').val().split('-')[0].trim() + " # " + $('.txtAssetDealerCode').val().split('-')[1].trim() : 'All') :
                        $('.ddlOption').val() == "1" && $('.ddlAssetPresent').val() == "4" ? ($('.txtAssetSSCode').val() != '' ? $('.txtAssetSSCode').val().split('-')[0].trim() + " # " + $('.txtAssetSSCode').val().split('-')[1].trim() : 'All') :
                        $('.ddlOption').val() == "1" && $('.ddlAssetPresent').val() == "5" ? ($('.txtAssetPlant').val() != '' ? $('.txtAssetPlant').val().split('-')[0].trim() + " # " + $('.txtAssetPlant').val().split('-')[1].trim() : 'All') :
                        $('.ddlOption').val() == "1" && $('.ddlAssetPresent').val() == "6" ? ($('.txtAssetlocation').val() != '' ? $('.txtAssetlocation').val().split('-')[0].trim() + " # " + $('.txtAssetlocation').val().split('-')[1].trim() : 'All') : "";

                        var headerRow1 = worksheet.getRow(1);
                        var headerRow2 = worksheet.getRow(2);
                        var headerRow3 = worksheet.getRow(3);
                        var headerRow6 = worksheet.getRow(5);
                        var headerRow7 = worksheet.getRow(6);
                        var headerRow8 = worksheet.getRow(7);

                        headerRow1.getCell(1).value = $("#lnkTitle").text();
                        headerRow2.getCell(1).value = 'From Date' + ' : ';
                        headerRow2.getCell(2).value = convertDateStringToDate($("#txtdxFromDate input[type='hidden']").val());
                        headerRow3.getCell(1).value = 'To Date' + ' : ';
                        headerRow3.getCell(2).value = convertDateStringToDate($("#txtdxToDate input[type='hidden']").val());
                        if ($('.ddlSearchFor option:selected').val() == "0") {
                            var headerRow4 = worksheet.getRow(4);
                            var headerRow5 = worksheet.getRow(4);
                            var headerRow7 = worksheet.getRow(6);
                            var headerRow8 = worksheet.getRow(7);
                            var headerRow9 = worksheet.getRow(8);
                            var headerRow10 = worksheet.getRow(9);
                            var headerRow11 = worksheet.getRow(10);
                            var headerRow12 = worksheet.getRow(11);
                            var headerRow13 = worksheet.getRow(12);
                            var headerRow14 = worksheet.getRow(13);
                            var headerRow15 = worksheet.getRow(14);
                            var headerRow16 = worksheet.getRow(15);

                            headerRow3.getCell(1).value = 'To Date' + ' : ';
                            headerRow3.getCell(2).value = convertDateStringToDate($("#txtdxToDate input[type='hidden']").val());
                            //headerRow4.getCell(1).value = 'Asset Scanned At' + ' : ';
                            //headerRow4.getCell(2).value = $('.ddlSearchFor option:selected').text();
                            headerRow5.getCell(1).value = 'Report Option' + ' : ';
                            headerRow5.getCell(2).value = $('.ddlOption option:selected').text();
                            headerRow6.getCell(1).value = 'Employee' + ' : ';
                            headerRow6.getCell(2).value = ($('.txtCode').val() != '' ? $('.txtCode').val().split('-')[0].trim() + " # " + $('.txtCode').val().split('-')[1].trim() : 'All');
                            headerRow7.getCell(1).value = 'Scanning Data Of' + ' : ';
                            headerRow7.getCell(2).value = $('.ddlReportBy option:selected').text();

                            if ($('.ddlOption').val() == "1") {
                                headerRow8.getCell(1).value = 'Report Type' + ' : ';
                                headerRow8.getCell(2).value = $('.ddlRptType option:selected').text();
                            }
                            if ($('.ddlOption').val() == "1") {
                                headerRow9.getCell(1).value = 'Scanning From' + ' : ';
                                headerRow9.getCell(2).value = $('.ddlScanFrom option:selected').text();
                            }

                            var headerDataCustRow = $('.ddlOption').val() == "1" ? headerRow10 : headerRow8;
                            var headerDataAssetAtRow = $('.ddlOption').val() == "1" ? headerRow11 : headerRow9;
                            var headerDataAssetAtCustRow = $('.ddlOption').val() == "1" && $('.ddlAssetPresent').val() != "0" && $('.ddlAssetPresent').val() != "7" && $('.ddlAssetPresent').val() != "8" ? headerRow12 : headerRow10;
                            var headerDataLatRow = $('.ddlOption').val() == "1" && $('.ddlAssetPresent').val() != "0" && $('.ddlAssetPresent').val() != "7" && $('.ddlAssetPresent').val() != "8" ? headerRow13 : headerRow12;
                            var headerDataUserRow = $('.ddlOption').val() == "1" && $('.ddlAssetPresent').val() != "0" && $('.ddlAssetPresent').val() != "7" && $('.ddlAssetPresent').val() != "8" ? headerRow14 : headerRow13;
                            var headerDataCreateRow = $('.ddlOption').val() == "1" && $('.ddlAssetPresent').val() != "0" && $('.ddlAssetPresent').val() != "7" && $('.ddlAssetPresent').val() != "8" ? headerRow15 : headerRow14;
                            var headerDataServerRow = $('.ddlOption').val() == "1" && $('.ddlAssetPresent').val() != "0" && $('.ddlAssetPresent').val() != "7" && $('.ddlAssetPresent').val() != "8" ? headerRow16 : headerRow15;

                            if ($('.ddlReportBy').val() == "2" || $('.ddlReportBy').val() == "6") {
                                headerDataCustRow.getCell(1).value = 'Distributor' + ' : ';
                                headerDataCustRow.getCell(2).value = ($('.txtDistCode').val() != '' ? $('.txtDistCode').val().split('-')[0].trim() + " # " + $('.txtDistCode').val().split('-')[1].trim() : 'All');
                            }
                            if ($('.ddlReportBy').val() == "4" || $('.ddlReportBy').val() == "7") {
                                headerDataCustRow.getCell(1).value = 'Super Stockist' + ' : ';
                                headerDataCustRow.getCell(2).value = ($('.txtSSCode').val() != '' ? $('.txtSSCode').val().split('-')[0].trim() + " # " + $('.txtSSCode').val().split('-')[1].trim() : 'All');
                            }
                            if ($('.ddlReportBy').val() == "5") {
                                headerDataCustRow.getCell(1).value = 'Dealer' + ' : ';
                                headerDataCustRow.getCell(2).value = ($('.txtDealerCode').val() != '' ? $('.txtDealerCode').val().split('-')[0].trim() + " # " + $('.txtDealerCode').val().split('-')[1].trim() : 'All');
                            }
                            if ($('.ddlOption').val() == "1") {
                                headerDataAssetAtRow.getCell(1).value = 'Asset Presently At' + ' : ';
                                headerDataAssetAtRow.getCell(2).value = $('.ddlAssetPresent option:selected').text();
                            }
                            if ($('.ddlOption').val() == "1" && $('.ddlAssetPresent').val() != "0" && $('.ddlAssetPresent').val() != "7" && $('.ddlAssetPresent').val() != "8") {
                                headerDataAssetAtCustRow.getCell(1).value = AssetAtCustLabel;
                                headerDataAssetAtCustRow.getCell(2).value = AssetAtCustText;
                            }
                            if ($('.ddlOption').val() == "1") {
                                headerDataLatRow.getCell(1).value = 'With LatLong' + ' : ';
                                headerDataLatRow.getCell(2).value = ($('.chkLatLong').find('input').is(':checked') ? "True" : "False");
                            }
                            if ($('.ddlOption').val() == "1") {
                                headerDataUserRow.getCell(1).value = 'User Name' + ' : ';
                                headerDataUserRow.getCell(2).value = $('.hdnUserName').val();
                                headerDataCreateRow.getCell(1).value = 'Created on' + ' : ';
                                headerDataCreateRow.getCell(2).value = (new Date().format('dd-MMM-yy HH:mm'));
                                headerDataServerRow.getCell(1).value = 'Version' + ' : ';
                                headerDataServerRow.getCell(2).value = Version;
                            }
                            if ($('.ddlOption').val() == "2") {
                                headerRow9.getCell(1).value = 'User Name' + ' : ';
                                headerRow9.getCell(2).value = $('.hdnUserName').val();
                                headerRow10.getCell(1).value = 'Created on' + ' : ';
                                headerRow10.getCell(2).value = (new Date().format('dd-MMM-yy HH:mm'));
                                headerRow11.getCell(1).value = 'Version' + ' : ';
                                headerRow11.getCell(2).value = Version;
                            }
                        }
                        else if ($('.ddlSearchFor option:selected').val() == "1") {
                            var headerRow4 = worksheet.getRow(4);
                            var headerRow5 = worksheet.getRow(5);

                            //headerRow4.getCell(1).value = 'Asset Scanned At' + ' : ';
                            //headerRow4.getCell(2).value = $('.ddlSearchFor option:selected').text();
                            headerRow5.getCell(1).value = 'Report Option' + ' : ';
                            headerRow5.getCell(2).value = $('.ddlOption option:selected').text();
                            if ($('.ddlOption').val() == "1") {
                                var headerRow6 = worksheet.getRow(6);
                                var headerRow7 = worksheet.getRow(7);
                                var headerRow8 = worksheet.getRow(8);
                                var headerRow9 = worksheet.getRow(9);
                                var headerRow10 = worksheet.getRow(10);
                                var headerRow11 = worksheet.getRow(11);
                                var headerRow12 = worksheet.getRow(12);
                                var headerRow13 = worksheet.getRow(13);

                                var headerDataAssetAtCustRow = $('.ddlOption').val() == "1" && $('.ddlAssetPresent').val() != "0" && $('.ddlAssetPresent').val() != "7" && $('.ddlAssetPresent').val() != "8" ? headerRow10 : headerRow11;
                                var headerDataUserRow = $('.ddlOption').val() == "1" && $('.ddlAssetPresent').val() != "0" && $('.ddlAssetPresent').val() != "7" && $('.ddlAssetPresent').val() != "8" ? headerRow11 : headerRow10;
                                var headerDataCreateRow = $('.ddlOption').val() == "1" && $('.ddlAssetPresent').val() != "0" && $('.ddlAssetPresent').val() != "7" && $('.ddlAssetPresent').val() != "8" ? headerRow12 : headerRow11;
                                var headerDataServerRow = $('.ddlOption').val() == "1" && $('.ddlAssetPresent').val() != "0" && $('.ddlAssetPresent').val() != "7" && $('.ddlAssetPresent').val() != "8" ? headerRow13 : headerRow12;

                                headerRow6.getCell(1).value = 'Report Type' + ' : ';
                                headerRow6.getCell(2).value = $('.ddlRptType option:selected').text();
                                headerRow7.getCell(1).value = 'Scanning From' + ' : ';
                                headerRow7.getCell(2).value = $('.ddlScanFrom option:selected').text();
                                headerRow8.getCell(1).value = 'Plant' + ' : ';
                                headerRow8.getCell(2).value = ($('.txtPlant').val() != '' ? $('.txtPlant').val().split('-')[0].trim() + " # " + $('.txtPlant').val().split('-')[1].trim() : '');
                                headerRow9.getCell(1).value = 'Asset Presently At' + ' : ';
                                headerRow9.getCell(2).value = $('.ddlAssetPresent option:selected').text();
                                if ($('.ddlOption').val() == "1" && $('.ddlAssetPresent').val() != "0") {
                                    headerDataAssetAtCustRow.getCell(1).value = AssetAtCustLabel;
                                    headerDataAssetAtCustRow.getCell(2).value = AssetAtCustText;
                                }
                                headerDataUserRow.getCell(1).value = 'User Name' + ' : ';
                                headerDataUserRow.getCell(2).value = $('.hdnUserName').val();
                                headerDataCreateRow.getCell(1).value = 'Created on' + ' : ';
                                headerDataCreateRow.getCell(2).value = (new Date().format('dd-MMM-yy HH:mm'));
                                headerDataServerRow.getCell(1).value = 'Version' + ' : ';
                                headerDataServerRow.getCell(2).value = Version;
                            }
                            else {
                                headerRow6.getCell(1).value = 'Plant' + ' : ';
                                headerRow6.getCell(2).value = ($('.txtPlant').val() != '' ? $('.txtPlant').val().split('-')[0].trim() + " # " + $('.txtPlant').val().split('-')[1].trim() : '');
                                headerRow7.getCell(1).value = 'User Name' + ' : ';
                                headerRow7.getCell(2).value = $('.hdnUserName').val();
                                headerRow8.getCell(1).value = 'Created on' + ' : ';
                                headerRow8.getCell(2).value = (new Date().format('dd-MMM-yy HH:mm'));
                                headerRow9.getCell(1).value = 'Version' + ' : ';
                                headerRow9.getCell(2).value = Version;
                            }
                        }
                        else if ($('.ddlSearchFor option:selected').val() == "2") {
                            var headerRow4 = worksheet.getRow(4);
                            var headerRow5 = worksheet.getRow(5);

                            //headerRow4.getCell(1).value = 'Asset Scanned At' + ' : ';
                            //headerRow4.getCell(2).value = $('.ddlSearchFor option:selected').text();
                            headerRow5.getCell(1).value = 'Report Option' + ' : ';
                            headerRow5.getCell(2).value = $('.ddlOption option:selected').text();
                            if ($('.ddlOption').val() == "1") {
                                var headerRow6 = worksheet.getRow(6);
                                var headerRow7 = worksheet.getRow(7);
                                var headerRow8 = worksheet.getRow(8);
                                var headerRow9 = worksheet.getRow(9);
                                var headerRow10 = worksheet.getRow(10);
                                var headerRow11 = worksheet.getRow(11);
                                var headerRow12 = worksheet.getRow(12);
                                var headerRow13 = worksheet.getRow(13);

                                var headerDataAssetAtCustRow = $('.ddlOption').val() == "1" && $('.ddlAssetPresent').val() != "0" && $('.ddlAssetPresent').val() != "7" && $('.ddlAssetPresent').val() != "8" ? headerRow10 : headerRow11;
                                var headerDataUserRow = $('.ddlOption').val() == "1" && $('.ddlAssetPresent').val() != "0" && $('.ddlAssetPresent').val() != "7" && $('.ddlAssetPresent').val() != "8" ? headerRow11 : headerRow10;
                                var headerDataCreateRow = $('.ddlOption').val() == "1" && $('.ddlAssetPresent').val() != "0" && $('.ddlAssetPresent').val() != "7" && $('.ddlAssetPresent').val() != "8" ? headerRow12 : headerRow11;
                                var headerDataServerRow = $('.ddlOption').val() == "1" && $('.ddlAssetPresent').val() != "0" && $('.ddlAssetPresent').val() != "7" && $('.ddlAssetPresent').val() != "8" ? headerRow13 : headerRow12;

                                headerRow6.getCell(1).value = 'Report Type' + ' : ';
                                headerRow6.getCell(2).value = $('.ddlRptType option:selected').text();
                                headerRow7.getCell(1).value = 'Scanning From' + ' : ';
                                headerRow7.getCell(2).value = $('.ddlScanFrom option:selected').text();
                                headerRow9.getCell(1).value = 'Asset Presently At' + ' : ';
                                headerRow9.getCell(2).value = $('.ddlAssetPresent option:selected').text();
                                headerRow8.getCell(1).value = 'Storage Location' + ' : ';
                                headerRow8.getCell(2).value = ($('.txtlocation').val() != '' ? $('.txtlocation').val().split('-')[0].trim() + " # " + $('.txtlocation').val().split('-')[1].trim() : '');
                                if ($('.ddlOption').val() == "1" && $('.ddlAssetPresent').val() != "0") {
                                    headerDataAssetAtCustRow.getCell(1).value = AssetAtCustLabel;
                                    headerDataAssetAtCustRow.getCell(2).value = AssetAtCustText;
                                }
                                headerDataUserRow.getCell(1).value = 'User Name' + ' : ';
                                headerDataUserRow.getCell(2).value = $('.hdnUserName').val();
                                headerDataCreateRow.getCell(1).value = 'Created on' + ' : ';
                                headerDataCreateRow.getCell(2).value = (new Date().format('dd-MMM-yy HH:mm'));
                                headerDataServerRow.getCell(1).value = 'Version' + ' : ';
                                headerDataServerRow.getCell(2).value = Version;
                            }
                            else {
                                headerRow6.getCell(1).value = 'Storage Location' + ' : ';
                                headerRow6.getCell(2).value = ($('.txtlocation').val() != '' ? $('.txtlocation').val().split('-')[0].trim() + " # " + $('.txtlocation').val().split('-')[1].trim() : '');
                                headerRow7.getCell(1).value = 'User Name' + ' : ';
                                headerRow7.getCell(2).value = $('.hdnUserName').val();
                                headerRow8.getCell(1).value = 'Created on' + ' : ';
                                headerRow8.getCell(2).value = (new Date().format('dd-MMM-yy HH:mm'));
                                headerRow9.getCell(1).value = 'Version' + ' : ';
                                headerRow9.getCell(2).value = Version;
                            }
                        }
                        else if ($('.ddlSearchFor option:selected').val() == "3") {
                            var headerRow4 = worksheet.getRow(4);
                            var headerRow5 = worksheet.getRow(5);
                            var headerRow6 = worksheet.getRow(6);
                            var headerRow7 = worksheet.getRow(7);
                            //headerRow4.getCell(1).value = 'Asset Scanned At' + ' : ';
                            //headerRow4.getCell(2).value = $('.ddlSearchFor option:selected').text();
                            headerRow5.getCell(1).value = 'Report Option' + ' : ';
                            headerRow5.getCell(2).value = $('.ddlOption option:selected').text();
                            if ($('.ddlOption').val() == "1") {
                                var headerRow6 = worksheet.getRow(6);
                                var headerRow7 = worksheet.getRow(7);
                                var headerRow8 = worksheet.getRow(8);
                                var headerRow9 = worksheet.getRow(9);
                                var headerRow10 = worksheet.getRow(10);

                                headerRow6.getCell(1).value = 'Report Type' + ' : ';
                                headerRow6.getCell(2).value = $('.ddlRptType option:selected').text();
                                headerRow7.getCell(1).value = 'Scanning From' + ' : ';
                                headerRow7.getCell(2).value = $('.ddlScanFrom option:selected').text();
                                headerRow8.getCell(1).value = 'User Name' + ' : ';
                                headerRow8.getCell(2).value = $('.hdnUserName').val();
                                headerRow9.getCell(1).value = 'Created on' + ' : ';
                                headerRow9.getCell(2).value = (new Date().format('dd-MMM-yy HH:mm'));
                                headerRow10.getCell(1).value = 'Version' + ' : ';
                                headerRow10.getCell(2).value = Version;
                            }
                            else {
                                headerRow6.getCell(1).value = 'User Name' + ' : ';
                                headerRow6.getCell(2).value = $('.hdnUserName').val();
                                headerRow7.getCell(1).value = 'Created on' + ' : ';
                                headerRow7.getCell(2).value = (new Date().format('dd-MMM-yy HH:mm'));
                                headerRow8.getCell(1).value = 'Version' + ' : ';
                                headerRow8.getCell(2).value = Version;
                            }
                        }
                        else if ($('.ddlSearchFor option:selected').val() == "4") {
                            var headerRow4 = worksheet.getRow(4);
                            var headerRow5 = worksheet.getRow(5);
                            var headerRow6 = worksheet.getRow(6);
                            var headerRow7 = worksheet.getRow(7);
                            //headerRow4.getCell(1).value = 'Asset Scanned At' + ' : ';
                            //headerRow4.getCell(2).value = $('.ddlSearchFor option:selected').text();
                            headerRow5.getCell(1).value = 'Report Option' + ' : ';
                            headerRow5.getCell(2).value = $('.ddlOption option:selected').text();
                            if ($('.ddlOption').val() == "1") {
                                var headerRow6 = worksheet.getRow(6);
                                var headerRow7 = worksheet.getRow(7);
                                var headerRow8 = worksheet.getRow(8);
                                var headerRow9 = worksheet.getRow(9);
                                var headerRow10 = worksheet.getRow(10);

                                headerRow6.getCell(1).value = 'Report Type' + ' : ';
                                headerRow6.getCell(2).value = $('.ddlRptType option:selected').text();
                                headerRow7.getCell(1).value = 'Scanning From' + ' : ';
                                headerRow7.getCell(2).value = $('.ddlScanFrom option:selected').text();
                                headerRow8.getCell(1).value = 'User Name' + ' : ';
                                headerRow8.getCell(2).value = $('.hdnUserName').val();
                                headerRow9.getCell(1).value = 'Created on' + ' : ';
                                headerRow9.getCell(2).value = (new Date().format('dd-MMM-yy HH:mm'));
                                headerRow10.getCell(1).value = 'Version' + ' : ';
                                headerRow10.getCell(2).value = Version;
                            }
                            else {
                                headerRow6.getCell(1).value = 'User Name' + ' : ';
                                headerRow6.getCell(2).value = $('.hdnUserName').val();
                                headerRow7.getCell(1).value = 'Created on' + ' : ';
                                headerRow7.getCell(2).value = (new Date().format('dd-MMM-yy HH:mm'));
                                headerRow8.getCell(1).value = 'Version' + ' : ';
                                headerRow8.getCell(2).value = Version;
                            }
                        }
                    }).then(function () {
                        workbook.xlsx.writeBuffer().then(function (buffer) {
                            saveAs(new Blob([buffer], { type: 'application/octet-stream' }), $("#lnkTitle").text() + '_' + new Date().toLocaleDateString() + '.xlsx');
                        });
                    });
                    e.cancel = true;
                },
                columns: [
                     { caption: "Sr", dataField: "Sr", alignment: "center", minWidth: 50 },
                     { dataField: "AssetPresentlyAt", minWidth: 150 },
                     { caption: "City", dataField: "PresentCity", visible: $('.ddlOption option:selected').val() == "1", minWidth: 70 },
                     { caption: $('.ddlOption option:selected').val() == "1" ? "Status" : "SAP Status", dataField: "Status", minWidth: 50 },
                     { caption: "Asset Sr.No", dataField: "AssetSrNo", minWidth: 50 },
                     { caption: "Sr", dataField: "SRNO", alignment: "center", visible: $('.ddlOption option:selected').val() == "1", minWidth: 50 },
                     { caption: "LGM Date", dataField: "LGMDate", dataType: "date", format: "dd-MMM-yy", alignment: "center", minWidth: 90 },
                     { caption: "Scan Date/Time", dataField: "ScanDateTime", dataType: "date", format: "dd-MMM-yy HH:mm", alignment: "center", visible: $('.ddlOption option:selected').val() == "1", minWidth: 100 },
                     { caption: "Asset Scanned At", dataField: "AssetPhysicalAt", visible: $('.ddlOption option:selected').val() == "1", minWidth: 150 },
                     { caption: "City", dataField: "City", visible: $('.ddlOption option:selected').val() == "1", minWidth: 70 },
                     { caption: "Status", dataField: "PhysicalStatus", visible: $('.ddlOption option:selected').val() == "1", minWidth: 70 },
                     { caption: "Asset as per Book at Scanned Time", dataField: "AssetasperBook", visible: $('.ddlOption option:selected').val() == "1", minWidth: 200 },
                     { caption: "City", dataField: "BookCity", visible: $('.ddlOption option:selected').val() == "1", minWidth: 50 },
                     { caption: "Status", dataField: "BookStatus", visible: $('.ddlOption option:selected').val() == "1", minWidth: 50 },
                     { caption: "Scan By", dataField: "ScanBy", visible: $('.ddlOption option:selected').val() == "1", minWidth: 50 },
                     { caption: "Conflict Status", dataField: "ConflictStatus", visible: $('.ddlOption option:selected').val() == "1", minWidth: 100 },
                     { caption: "Scanning Option", dataField: "ScanningOption", visible: $('.ddlOption option:selected').val() == "1", minWidth: 100 },
                     { caption: "Scanning Through", dataField: "ScanningThrough", visible: $('.ddlOption option:selected').val() == "1", minWidth: 110 },
                     { caption: "Remarks", dataField: "Remarks", visible: $('.ddlOption option:selected').val() == "1", minWidth: 50 },
                     { caption: "Lat", dataField: "Lat", visible: ($('.ddlOption option:selected').val() == "1" && $('.chkLatLong').find('input').is(':checked')), minWidth: 50 },
                     { caption: "Long", dataField: "Long", visible: ($('.ddlOption option:selected').val() == "1" && $('.chkLatLong').find('input').is(':checked')), minWidth: 50 },
                     { caption: "Address", dataField: "Address", visible: ($('.ddlOption option:selected').val() == "1" && $('.chkLatLong').find('input').is(':checked')), minWidth: 50 },
                     { caption: "Beat Employee", dataField: "BeatEmployee", visible: $('.ddlOption option:selected').val() == "2", minWidth: 50 },
                     { caption: $('.ddlOption option:selected').val() == "1" ? "Current  Parent Code/Name" : "Parent Code & Name", dataField: "ParentCodeName", minWidth: 150 },
                     { caption: "Parent Beat Employee", dataField: "ParentBeatEmp", minWidth: 150 },
                ],
                onContentReady: function (e) {
                    if (!collapsed) {
                        collapsed = true;
                        e.component.expandRow(["EnviroCare"]);
                    }
                    //e.element.find(".dx-datagrid-export-button").dxButton("instance").option("text", "Export To Excel");

                }
            }).dxDataGrid("instance");
            //$('#exportButton').dxButton({
            //    icon: 'exportpdf',
            //    text: 'Export to PDF',
            //    format: "A4", landscape: true,
            //    onClick: function () {
            //        const pdfDoc = new jsPDF('l', 'pt', 'a4');
            //        pdfDoc.addImage(imagebase64, 752, 20, 70, 50);
            //        pdfDoc.setFontSize(10);
            //        const pageCount = pdfDoc.internal.getNumberOfPages();
            //        for (let i = 1; i <= pageCount; i++) {
            //            pdfDoc.setPage(i);
            //            const pageSize = pdfDoc.internal.pageSize;
            //            const pageWidth = pageSize.width ? pageSize.width : pageSize.getWidth();
            //            const pageHeight = pageSize.height ? pageSize.height : pageSize.getHeight();
            //            const header = $("#lnkTitle").text() + "\n" +
            //                'From Date' + ' : ' + $("#txtdxFromDate input[type='hidden']").val() + "\n" +
            //                'To Date' + ' : ' + $("#txtdxToDate input[type='hidden']").val() + "\n" +
            //                'Asset Scanned At' + ' : ' + $('.ddlSearchFor option:selected').text() + "\n" +
            //                'Report Option' + ' : ' + $('.ddlOption option:selected').text() + "\n" +
            //                'Employee' + ' : ' + $('.txtCode').val() + "\n" +
            //                'Scanning Data Of' + ' : ' + $('.ddlReportBy option:selected').text() + "\n" +
            //                'Distributor' + ' : ' + $('.txtDistCode').val() + "\n" +
            //                'Dealer' + ' : ' + $('.txtDealerCode').val() + "\n" +
            //                'Super Stockist' + ' : ' + $('.txtSSCode').val() + "\n" +
            //                'Plant' + ' : ' + $('.txtPlant').val() + "\n" +
            //                'Storage Location' + ' : ' + $('.txtlocation').val() + "\n"
            //            ;
            //            const footer = 'Page ${i} of ${pageCount}';

            //            // Header
            //            pdfDoc.text(header, 20, 20, { baseline: 'top' }, { styles: { fontSize: 7 } });

            //            // Footer
            //            pdfDoc.text(footer, pageWidth / 2 - (pdfDoc.getTextWidth(footer) / 2), pageHeight - 15, { baseline: 'bottom' });
            //        }
            //        DevExpress.pdfExporter.exportDataGrid({
            //            jsPDFDocument: pdfDoc,
            //            component: dataGrid,

            //            autoTableOptions: {
            //                theme: 'grid',
            //                tableWidth: 'auto',
            //                showHeader: 'everyPage',
            //                columnStyles: {
            //                    0: { columnWidth: 15 },
            //                    1: { columnWidth: 50 },
            //                    2: { columnWidth: 30 },
            //                    3: { columnWidth: 25 },
            //                    4: { columnWidth: 60 },
            //                    5: { columnWidth: 20 },
            //                    6: { columnWidth: 30 },
            //                    7: { columnWidth: 50 },
            //                    8: { columnWidth: 50 },
            //                    9: { columnWidth: 30 },
            //                    10: { columnWidth: 25 },
            //                    11: { columnWidth: 30 },
            //                    12: { columnWidth: 30 },
            //                    13: { columnWidth: 25 },
            //                    14: { columnWidth: 40 },
            //                    15: { columnWidth: 30 },
            //                    16: { columnWidth: 30 },
            //                    17: { columnWidth: 30 },
            //                    18: { columnWidth: 30 },
            //                    19: { columnWidth: 30 },
            //                    20: { columnWidth: 30 },
            //                    21: { columnWidth: 50 },
            //                    22: { columnWidth: 50 },
            //                    23: { columnWidth: 50 }
            //                },
            //                styles: {
            //                    fontSize: 6,
            //                    columnWidth: 'wrap',
            //                    valign: 'middle',
            //                    halign: 'center',
            //                    overflow: 'linebreak',
            //                    cellPadding: 1,
            //                    overflowColumns: 'linebreak'
            //                },
            //                alternateRowStyles: {
            //                    fillColor: [243, 243, 243]
            //                },
            //                headStyles: {
            //                    fillColor: [45, 65, 84],
            //                    textColor: [255, 255, 255],
            //                    fontStyle: 'bold',
            //                    fontSize: 7
            //                },
            //                margin: { left: 20, top: 115, right: 20, bottom: 30 },
            //            }
            //        }).then(function () {
            //            pdfDoc.save($("#lnkTitle").text() + '_' + new Date().toLocaleDateString());
            //        });
            //    }
            //});
        }

        function GETDATA() {
            $('.dx-overlay-modal').show();
            var FromDate = $("#txtdxFromDate input[type='hidden']").val();
            var ToDate = $("#txtdxToDate input[type='hidden']").val();
            //if (CustType==1&&$('.ddlSearchFor option:selected').val() == "0" && $('.txtDistCode').val().split("-").pop() == 0 && $('.txtSSCode').val().split("-").pop() == 0 && $('.txtDealerCode').val().split("-").pop() == 0 && $('.txtCode').val().split("-").pop() == 0) {
            //    if ($('.ddlAssetPresent option:selected').val() != "0" || $('.ddlAssetPresent option:selected').val() != "7" || $('.ddlAssetPresent option:selected').val() != "8") {
            //        if ($('.txtAssetDealerCode').val() == '' && $('.txtAssetDistCode').val() == '' && $('.txtAssetSSCode').val() == '' && $('.txtAssetPlant').val() == '' && $('.txtAssetlocation').val() == '') {
            //            ModelMsg('Please select at least one parameter.', 3);
            //            return;
            //        }
            //    }
            //}
            if ($('.ddlSearchFor option:selected').val() == "1" && $('.txtPlant').val() != "" && $('.txtPlant').val().split("-").length < 3) {
                ModelMsg('Please select proper plant.', 3);
                return;
            }
            else if ($('.ddlSearchFor option:selected').val() == "1" && $('.txtPlant').val() != "" && isNaN($('.txtPlant').val().split("-").pop())) {
                ModelMsg('Please select proper plant.', 3);
                return;
            }
            if ($('.ddlSearchFor option:selected').val() == "2" && $('.txtlocation').val() != "" && $('.txtlocation').val().split("-").length < 3) {
                ModelMsg('Please select proper storage location.', 3);
                return;
            }
            else if ($('.ddlSearchFor option:selected').val() == "2" && $('.txtlocation').val() != "" && isNaN($('.txtlocation').val().split("-").pop())) {
                ModelMsg('Please select proper storage location.', 3);
                return;
            }
            else if ($('.ddlAssetPresent option:selected').val() == "2" && $('.txtAssetDistCode').val() != "" && isNaN($('.txtAssetDistCode').val().split("-").pop())) {
                ModelMsg('Please select proper Asset Presently At Distributor.', 3);
                return;
            }
            else if ($('.ddlAssetPresent option:selected').val() == "3" && $('.txtAssetDealerCode').val() != "" && isNaN($('.txtAssetDealerCode').val().split("-").pop())) {
                ModelMsg('Please select proper Asset Presently At Dealer.', 3);
                return;
            }
            else if ($('.ddlAssetPresent option:selected').val() == "4" && $('.txtAssetSSCode').val() != "" && isNaN($('.txtAssetSSCode').val().split("-").pop())) {
                ModelMsg('Please select proper Asset Presently At Super Stockist.', 3);
                return;
            }
            else if ($('.ddlAssetPresent option:selected').val() == "5" && $('.txtAssetPlant').val() != "" && isNaN($('.txtAssetPlant').val().split("-").pop())) {
                ModelMsg('Please select proper Asset Presently At Plant.', 3);
                return;
            }
            else if ($('.ddlAssetPresent option:selected').val() == "6" && $('.txtAssetlocation').val() != "" && isNaN($('.txtAssetlocation').val().split("-").pop())) {
                ModelMsg('Please select proper Asset Presently At Storage Location.', 3);
                return;
            }
            load(0);

            $.ajax({
                type: "POST",
                url: "AssetScanNotScanList.aspx/GetData",
                dataType: "json",
                data: "{ 'Fromdate': '" + FromDate + "','Todate': '" + ToDate + "','ReportBy': '" + $('.ddlReportBy option:selected').val() + "','ReportType': '" + $('.ddlRptType option:selected').val() +
                    "','ReportOption': '" + $('.ddlOption option:selected').val() + "','ReportScanFrom': '" + $('.ddlScanFrom option:selected').val() + "','SearchFor': '"
                    + $('.ddlSearchFor option:selected').val() + "','DistCode': '" + ($('.txtDistCode').val() != '' ? $('.txtDistCode').val().split("-").pop() : 0) +
                    "','SSDistCode': '" + ($('.txtSSCode').val() != '' ? $('.txtSSCode').val().split("-").pop() : 0) + "','DealerCode': '"
                    + ($('.txtDealerCode').val() != '' ? $('.txtDealerCode').val().split("-").pop() : 0) + "','PlantID': '" +
                    ($('.txtPlant').val() != '' ? $('.txtPlant').val().split("-").pop() : 0) + "','StoreLocID': '" + ($('.txtlocation').val() != '' ? $('.txtlocation').val().split("-").pop() : 0)
                    + "','IsAssetPresentlyAt': '" + ($('.ddlAssetPresent option:selected').val())
                    + "','txtCode': '" + ($('.txtCode').val() != '' ? $('.txtCode').val().split("-").pop() : 0)
                    + "','AssetDistCode': '" + ($('.txtAssetDistCode').val() != '' ? $('.txtAssetDistCode').val().split("-").pop() : 0)
                    + "','AssetSSDistCode': '" + ($('.txtAssetSSCode').val() != '' ? $('.txtAssetSSCode').val().split("-").pop() : 0)
                    + "','AssetDealerCode': '" + ($('.txtAssetDealerCode').val() != '' ? $('.txtAssetDealerCode').val().split("-").pop() : 0)
                    + "','AssetPlantCode': '" + ($('.txtAssetPlant').val() != '' ? $('.txtAssetPlant').val().split("-").pop() : 0)
                    + "','AssetStoreLocCode': '" + ($('.txtAssetlocation').val() != '' ? $('.txtAssetlocation').val().split("-").pop() : 0) + "'}",
                contentType: "application/json; charset=utf-8",
                success: function (result) {
                    //if (result.d[0] == "" || result.d[0] == undefined) {
                    //    load(1);
                    //    FillGrid(result.d[0]);
                    //    return false;
                    //}
                    //else
                    if (result.d.Status == false) {
                        $.unblockUI();
                        load(1);
                        //var grid = $('#gridContainer').dxDataGrid('instance');
                        //grid.option('dataSource', []);
                        FillGrid(result.d.Data);
                        ExportToExcelLabel();
                        $('.dx-overlay-modal').hide();
                        ModelMsg(result.d.Message, 3);
                        return false;
                    }
                    else {
                        FillGrid(result.d.Data);
                        ExportToExcelLabel();
                        load(1);
                    }
                },
                error: function (error, errorThrow) {
                    var error = errorThrow;
                    ModelMsg("Please refresh the page and try again", 3);
                    load(1);
                }
            });
        }

        function ClearOtherConfig() {
            if ($(this).length > 0) {
                $(".txtDistCode").val('');
                $(".txtSSCode").val('');
                $(".txtDealerCode").val('');
                $(".txtAssetDistCode").val('');
                $(".txtAssetSSCode").val('');
                $(".txtAssetDealerCode").val('');
            }
        }
        function ChangeReport() {
            if ($('.ddlReportBy').val() == "2" || $('.ddlReportBy').val() == "6") {
                $(".txtSSCode").val("");
                $(".txtDealerCode").val("");
                $('.divDist').removeAttr('style');
                $('.divSS').attr('style', 'display:none;');
                $('.divDealer').attr('style', 'display:none;');
            }
            else if ($('.ddlReportBy').val() == "4" || $('.ddlReportBy').val() == "7") {
                $(".txtDistCode").val("");
                $(".txtDealerCode").val("");
                $('.divDist').attr('style', 'display:none;');
                $('.divSS').removeAttr('style');
                $('.divDealer').attr('style', 'display:none;');
            }
            else if ($('.ddlReportBy').val() == "5") {
                $(".txtDistCode").val("");
                $(".txtSSCode").val("");
                $('.divDist').attr('style', 'display:none;');
                $('.divSS').attr('style', 'display:none;');
                $('.divDealer').removeAttr('style');
            }
            else {
                $(".txtDistCode").val("");
                $(".txtSSCode").val("");
                $(".txtDealerCode").val("");
                $('.divDist').attr('style', 'display:none;');
                $('.divSS').attr('style', 'display:none;');
                $('.divDealer').attr('style', 'display:none;');
            }
        }
        function ChangeSearch() {
            if ($('.ddlSearchFor').val() == "1") {
                $('.divPlant').removeAttr('style');
                //$('.divFromDate').attr('style', 'display:none;');
                //$('.divToDate').attr('style', 'display:none;');
                $('.divReportBy').attr('style', 'display:none;');
                $('.divEmpCode').attr('style', 'display:none;');
                $('.divDist').attr('style', 'display:none;');
                $('.divSS').attr('style', 'display:none;');
                $('.divDealer').attr('style', 'display:none;');
                $('.divStore').attr('style', 'display:none;');
                //$('.divOption').attr('style', 'display:none;');
                $('.divScan').attr('style', 'display:none;');
                $('.divLatLong').attr('style', 'display:none;');
                $('.divAssetPresent').attr('style', 'display:none;');
                $('.divAssetCust').attr('style', 'display:none;');

                if ($('.ddlOption').val() == "1") {
                    $('.divRptType').removeAttr('style');
                    $('.divScan').removeAttr('style');
                    $('.divAssetPresent').removeAttr('style');
                    $('.divAssetCust').removeAttr('style');
                }
                else {
                    $('.divRptType').attr('style', 'display:none;');
                }
            }
            else if ($('.ddlSearchFor').val() == "2") {
                $('.divStore').removeAttr('style');
                //$('.divFromDate').attr('style', 'display:none;');
                //$('.divToDate').attr('style', 'display:none;');
                $('.divReportBy').attr('style', 'display:none;');
                $('.divEmpCode').attr('style', 'display:none;');
                $('.divDist').attr('style', 'display:none;');
                $('.divSS').attr('style', 'display:none;');
                $('.divDealer').attr('style', 'display:none;');
                $('.divPlant').attr('style', 'display:none;');
                //$('.divOption').attr('style', 'display:none;');
                $('.divScan').attr('style', 'display:none;');
                $('.divLatLong').attr('style', 'display:none;');
                $('.divAssetPresent').attr('style', 'display:none;');
                $('.divAssetCust').attr('style', 'display:none;');

                if ($('.ddlOption').val() == "1") {
                    $('.divRptType').removeAttr('style');
                    $('.divScan').removeAttr('style');
                    $('.divAssetPresent').removeAttr('style');
                    $('.divAssetCust').removeAttr('style');
                }
                else {
                    $('.divRptType').attr('style', 'display:none;');
                }
            }
            else if ($('.ddlSearchFor').val() == "3" || $('.ddlSearchFor').val() == "4") {
                $('.divStore').attr('style', 'display:none;');
                $('.divPlant').attr('style', 'display:none;');
                //$('.divFromDate').attr('style', 'display:none;');
                //$('.divToDate').attr('style', 'display:none;');
                $('.divReportBy').attr('style', 'display:none;');
                $('.divEmpCode').attr('style', 'display:none;');
                $('.divDist').attr('style', 'display:none;');
                $('.divSS').attr('style', 'display:none;');
                $('.divDealer').attr('style', 'display:none;');
                $('.divPlant').attr('style', 'display:none;');
                //$('.divOption').attr('style', 'display:none;');
                $('.divScan').attr('style', 'display:none;');
                $('.divLatLong').attr('style', 'display:none;');
                $('.divRptType').attr('style', 'display:none;');
                $('.divAssetPresent').attr('style', 'display:none;');
                $('.divAssetCust').attr('style', 'display:none;');
                if ($('.ddlOption').val() == "1") {
                    $('.divRptType').removeAttr('style');
                    $('.divScan').removeAttr('style');
                    //$('.divAssetPresent').removeAttr('style');
                }
                else {
                    $('.divRptType').attr('style', 'display:none;');
                }
            }
            else {
                $('.divPlant').attr('style', 'display:none;');
                $('.divStore').attr('style', 'display:none;');
                //$('.divFromDate').removeAttr('style');
                //$('.divToDate').removeAttr('style');
                $('.divReportBy').removeAttr('style');
                $('.divEmpCode').removeAttr('style');
                $('.divDist').removeAttr('style');
                $('.divSS').removeAttr('style');
                $('.divDealer').removeAttr('style');
                //$('.divOption').removeAttr('style');
                $('.divScan').removeAttr('style');
                $('.ddlDropdown').prop('selectedIndex', 0);
                if ($('.ddlOption').val() == "1") {
                    $('.divLatLong').removeAttr('style');
                    $('.divAssetPresent').removeAttr('style');
                    $('.divAssetCust').removeAttr('style');
                    $('.divScan').removeAttr('style');
                    $('.divRptType').removeAttr('style');
                }
                else {
                    $('.divLatLong').attr('style', 'display:none;');
                    $('.divAssetPresent').attr('style', 'display:none;');
                    $('.divAssetCust').attr('style', 'display:none;');
                    $('.divScan').attr('style', 'display:none;');
                    $('.divRptType').attr('style', 'display:none;');
                }
                ChangeReport();
            }
            ChangeAssetAtReport();
            $(".txtClear").val("");
        }
        function ChangeAssetAtReport() {
            if ($('.ddlOption').val() == "2" || $('.ddlSearchFor').val() == "3" || $('.ddlSearchFor').val() == "4" || $('.ddlAssetPresent').val() == "0" || $('.ddlAssetPresent').val() == "7" || $('.ddlAssetPresent').val() == "8") {
                $('.divAssetCust').attr('style', 'display:none;');
                $(".txtAssetDistCode").val('');
                $(".txtAssetSSCode").val('');
                $(".txtAssetDealerCode").val('');
                $(".txtAssetPlant").val('');
                $(".txtAssetlocation").val('');
            }
            else if ($('.ddlOption').val() == "1") {
                $('.divAssetCust').removeAttr('style');
                if ($('.ddlAssetPresent').val() == "2") {
                    $('.divAssetDist').removeAttr('style');
                    $(".txtAssetSSCode").val('');
                    $(".txtAssetDealerCode").val('');
                    $(".txtAssetPlant").val('');
                    $(".txtAssetlocation").val('');
                    $('.divAssetSS').attr('style', 'display:none;');
                    $('.divAssetDealer').attr('style', 'display:none;');
                    $('.divAssetPlant').attr('style', 'display:none;');
                    $('.divAssetStore').attr('style', 'display:none;');
                }
                else if ($('.ddlAssetPresent').val() == "4") {
                    $('.divAssetSS').removeAttr('style');
                    $(".txtAssetDistCode").val('');
                    $(".txtAssetDealerCode").val('');
                    $(".txtAssetPlant").val('');
                    $(".txtAssetlocation").val('');
                    $('.divAssetDist').attr('style', 'display:none;');
                    $('.divAssetDealer').attr('style', 'display:none;');
                    $('.divAssetPlant').attr('style', 'display:none;');
                    $('.divAssetStore').attr('style', 'display:none;');
                }
                else if ($('.ddlAssetPresent').val() == "3") {
                    $('.divAssetDealer').removeAttr('style');
                    $(".txtAssetDistCode").val('');
                    $(".txtAssetSSCode").val('');
                    $(".txtAssetPlant").val('');
                    $(".txtAssetlocation").val('');
                    $('.divAssetSS').attr('style', 'display:none;');
                    $('.divAssetDist').attr('style', 'display:none;');
                    $('.divAssetPlant').attr('style', 'display:none;');
                    $('.divAssetStore').attr('style', 'display:none;');
                }
                else if ($('.ddlAssetPresent').val() == "5") {
                    $(".txtAssetDistCode").val('');
                    $(".txtAssetSSCode").val('');
                    $(".txtAssetDealerCode").val('');
                    $(".txtAssetlocation").val('');
                    $('.divAssetPlant').removeAttr('style');
                    $('.divAssetDealer').attr('style', 'display:none;');
                    $('.divAssetSS').attr('style', 'display:none;');
                    $('.divAssetDist').attr('style', 'display:none;');
                    $('.divAssetStore').attr('style', 'display:none;');
                }
                else if ($('.ddlAssetPresent').val() == "6") {
                    $(".txtAssetDistCode").val('');
                    $(".txtAssetSSCode").val('');
                    $(".txtAssetDealerCode").val('');
                    $(".txtAssetPlant").val('');
                    $('.divAssetStore').removeAttr('style');
                    $('.divAssetDealer').attr('style', 'display:none;');
                    $('.divAssetSS').attr('style', 'display:none;');
                    $('.divAssetDist').attr('style', 'display:none;');
                    $('.divAssetPlant').attr('style', 'display:none;');
                }
                else if ($('.ddlAssetPresent').val() == "0" || $('.ddlAssetPresent').val() == "7" || $('.ddlAssetPresent').val() == "8") {
                    $(".txtAssetDistCode").val('');
                    $(".txtAssetSSCode").val('');
                    $(".txtAssetDealerCode").val('');
                    $(".txtAssetPlant").val('');
                    $(".txtAssetlocation").val('');
                }
            }
        }
    </script>
    <style>
        #gridContainer {
            max-height: 410px;
        }

            #gridContainer td {
                font-size: 11px;
            }

        .dx-datagrid-filter-panel {
            display: none;
        }

        .dx-header-row .dx-header-filter-indicator, .dx-header-row .dx-sort-indicator {
            max-width: 100%;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <asp:HiddenField runat="server" ID="hdnIPAdd" ClientIDMode="Static" Value="0" />
    <div class="loadpanel"></div>
    <div class="panel">
        <div class="panel-body _masterForm">
            <div class="row">
                <div class="col-lg-4 divFromDate">
                    <div class="input-group">
                        <label class="input-group-addon">From Date</label>
                        <div class="dx-field">
                            <div id="txtdxFromDate"></div>
                        </div>
                    </div>
                </div>
                <div class="col-lg-4 divToDate">
                    <div class="input-group">
                        <label class="input-group-addon">To Date</label>
                        <div class="dx-field">
                            <div id="txtdxToDate"></div>
                        </div>
                    </div>
                </div>
                <div class="col-lg-4" style="display: none">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Asset Scanned At</label>
                        <asp:DropDownList runat="server" ID="ddlSearchFor" CssClass="ddlSearchFor form-control" onchange="ChangeSearch();" TabIndex="3">
                            <asp:ListItem Text="Dealer + Distributor + SS" Value="0" Selected="True" />
                            <asp:ListItem Text="Plant" Value="1" />
                            <asp:ListItem Text="Storage Location" Value="2" />
                            <asp:ListItem Text="Write-off" Value="3" />
                            <asp:ListItem Text="Scrap" Value="4" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4 divOption">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Report Option</label>
                        <asp:DropDownList runat="server" ID="ddlOption" CssClass="ddlOption form-control" onchange="ChangeSearch();" TabIndex="4">
                            <asp:ListItem Text="Asset Scan" Value="1" />
                            <asp:ListItem Text="Asset Not Scan" Value="2" />
                        </asp:DropDownList>
                    </div>
                </div>

                <div class="col-lg-4 divEmpCode" id="divEmpCode" runat="server">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Employee</label>
                        <asp:TextBox ID="txtCode" onchange="ClearOtherConfig()" runat="server" CssClass="form-control txtCode txtClear" Style="background-color: rgb(250, 255, 189);" TabIndex="5"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divReportBy">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Scanning Data Of</label>
                        <asp:DropDownList runat="server" ID="ddlReportBy" CssClass="ddlReportBy form-control ddlDropdown" onchange="ChangeReport();" TabIndex="6">
                            <asp:ListItem Text="Dealers Under Dist. OR All Dealer" Value="2" Selected="True" />
                            <asp:ListItem Text="Selected Dealers OR All Dealer" Value="5" />
                            <asp:ListItem Text="Distributors Under SS OR All Distributors" Value="4" />
                            <asp:ListItem Text="Selected Distributor OR All Distributors" Value="6" />
                            <asp:ListItem Text="Selected SS OR All SS" Value="7" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4 divRptType">
                    <div class="input-group form-group">
                        <asp:Label ID="lblRptType" runat="server" Text="Report Type" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlRptType" TabIndex="7" runat="server" CssClass="ddlRptType form-control">
                            <asp:ListItem Text="History" Value="1" Selected="True" />
                            <asp:ListItem Text="Last Scan" Value="2" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4 divScan">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Scanning From </label>
                        <asp:DropDownList runat="server" ID="ddlScanFrom" CssClass="ddlScanFrom ddlDropdown form-control" TabIndex="8">
                            <asp:ListItem Text="Both" Value="0" />
                            <asp:ListItem Text="Asset Scan" Value="1" />
                            <asp:ListItem Text="Order Taken Time " Value="2" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4 divDist">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Distributor</label>
                        <asp:TextBox ID="txtDistCode" runat="server" TabIndex="9" Style="background-color: rgb(250, 255, 189);" CssClass="txtDistCode form-control txtClear" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDistCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divSS" id="divSS" runat="server">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Super Stockist</label>
                        <asp:TextBox ID="txtSSCode" runat="server" TabIndex="10" Style="background-color: rgb(250, 255, 189);" CssClass="txtSSCode form-control txtClear" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="aceSStxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetSSCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteSSDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtSSCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divDealer">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Dealer</label>
                        <asp:TextBox ID="txtDealerCode" runat="server" TabIndex="11" Style="background-color: rgb(250, 255, 189);" CssClass="txtDealerCode form-control txtClear" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtDealerCode" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDealerFromCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="acetxtDealerCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDealerCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divPlant" id="divPlant" runat="server">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Plant</label>
                        <asp:TextBox ID="txtPlant" runat="server" TabIndex="12" Style="background-color: rgb(250, 255, 189);" CssClass="txtPlant form-control txtClear"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender2" runat="server"
                            ServiceMethod="GetPlantsCurrHierarchy" ServicePath="../Service.asmx" OnClientPopulating="autoCompletePlant_OnClientPopulating" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtPlant" UseContextKey="True">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divStore" id="divStore" runat="server">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Storage Location</label>
                        <asp:TextBox ID="txtlocation" runat="server" CssClass="form-control txtlocation txtClear" Style="background-color: rgb(250, 255, 189);" TabIndex="13"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" runat="server" ID="AutoCompleteExtender3" ServicePath="../WebService.asmx"
                            UseContextKey="true" MinimumPrefixLength="1" CompletionInterval="10" ServiceMethod="GetPlantStorageLocation"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtlocation">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divAssetPresent">
                    <div class="input-group form-group">
                        <asp:Label ID="lblAsseAtPresent" runat="server" Text="Asset Presently At" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlAssetPresent" CssClass="ddlAssetPresent form-control ddlDropdown" onchange="ChangeAssetAtReport();" TabIndex="14">
                            <asp:ListItem Text="All" Value="0" Selected="True" />
                            <asp:ListItem Text="Distributor" Value="2" />
                            <asp:ListItem Text="Super Stockist" Value="4" />
                            <asp:ListItem Text="Dealer" Value="3" />
                            <asp:ListItem Text="Plant" Value="5" />
                            <asp:ListItem Text="Storage Location" Value="6" />
                            <asp:ListItem Text="Write-off" Value="7" />
                            <asp:ListItem Text="Scrap" Value="8" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4 divAssetCust" id="divAssetCust" runat="server">
                    <div class="divAssetDist">
                        <div class="input-group form-group">
                            <label class="input-group-addon">Asset Presently Dist.</label>
                            <asp:TextBox ID="txtAssetDistCode" runat="server" TabIndex="15" Style="background-color: rgb(250, 255, 189);" CssClass="txtAssetDistCode form-control txtClear" autocomplete="off"></asp:TextBox>
                            <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender1" runat="server" ServicePath="~/Service.asmx"
                                UseContextKey="true" ServiceMethod="GetDistCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteAssetAtDistriCode_OnClientPopulating"
                                EnableCaching="false" CompletionSetCount="1" TargetControlID="txtAssetDistCode">
                            </asp:AutoCompleteExtender>
                        </div>
                    </div>
                    <div class="divAssetSS" id="divAssetSS" runat="server">
                        <div class="input-group form-group">
                            <label class="input-group-addon">Asset Presently SS</label>
                            <asp:TextBox ID="txtAssetSSCode" runat="server" TabIndex="16" Style="background-color: rgb(250, 255, 189);" CssClass="txtAssetSSCode form-control txtClear" autocomplete="off"></asp:TextBox>
                            <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender4" runat="server" ServicePath="~/Service.asmx"
                                UseContextKey="true" ServiceMethod="GetSSCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteAssetAtSSDistriCode_OnClientPopulating"
                                EnableCaching="false" CompletionSetCount="1" TargetControlID="txtAssetSSCode">
                            </asp:AutoCompleteExtender>
                        </div>
                    </div>
                    <div class="divAssetDealer" id="divAssetDealer" runat="server">
                        <div class="input-group form-group">
                            <label class="input-group-addon">Asset Presently Dlr</label>
                            <asp:TextBox ID="txtAssetDealerCode" runat="server" TabIndex="17" Style="background-color: rgb(250, 255, 189);" CssClass="txtAssetDealerCode form-control txtClear" autocomplete="off"></asp:TextBox>
                            <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender5" runat="server" ServicePath="~/Service.asmx"
                                UseContextKey="true" ServiceMethod="GetDealerFromCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="acetxtAssetAtDealerCode_OnClientPopulating"
                                EnableCaching="false" CompletionSetCount="1" TargetControlID="txtAssetDealerCode">
                            </asp:AutoCompleteExtender>
                        </div>
                    </div>
                    <div class="divAssetPlant" id="divAssetPlant" runat="server">
                        <div class="input-group form-group">
                            <label class="input-group-addon">Asset Presently Plant</label>
                            <asp:TextBox ID="txtAssetPlant" runat="server" TabIndex="18" Style="background-color: rgb(250, 255, 189);" CssClass="txtAssetPlant form-control txtClear"></asp:TextBox>
                            <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender6" runat="server"
                                ServiceMethod="GetPlantsCurrHierarchy" ServicePath="../Service.asmx" OnClientPopulating="autoCompleteAssetAtPlant_OnClientPopulating" MinimumPrefixLength="1" CompletionInterval="10"
                                EnableCaching="false" CompletionSetCount="1" TargetControlID="txtAssetPlant" UseContextKey="True">
                            </asp:AutoCompleteExtender>
                        </div>
                    </div>
                    <div class="divAssetStore" id="divAssetStore" runat="server">
                        <div class="input-group form-group">
                            <label class="input-group-addon">Asset Presently StorLoc</label>
                            <asp:TextBox ID="txtAssetlocation" runat="server" CssClass="form-control txtAssetlocation txtClear" Style="background-color: rgb(250, 255, 189);" TabIndex="19"></asp:TextBox>
                            <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" runat="server" ID="AutoCompleteExtender7" ServicePath="../WebService.asmx"
                                UseContextKey="true" MinimumPrefixLength="1" CompletionInterval="10" ServiceMethod="GetPlantStorageLocation"
                                EnableCaching="false" CompletionSetCount="1" TargetControlID="txtAssetlocation">
                            </asp:AutoCompleteExtender>
                        </div>
                    </div>
                </div>
                <div class="col-lg-4 divLatLong">
                    <div class="input-group form-group">
                        <asp:Label ID="lblLatLong" runat="server" Text="With LatLong" CssClass="input-group-addon"></asp:Label>
                        <asp:CheckBox CssClass="form-control chkLatLong" Checked="true" TabIndex="20" ID="chkLatLong" runat="server" ClientIDMode="Static" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <input type="hidden" class="hdnUserName" id="hdnUserName" runat="server" />
                        <input type="button" id="btnSubmit" name="Go" value="Go" class="btnSubmit btn btn-default" onclick="GETDATA();" tabindex="21" />
                    </div>
                </div>
            </div>
            <div class="demo-container" style="margin-top: -10px;">
                <div id="exportButton"></div>
                <div id="gridContainer"></div>
            </div>
        </div>
    </div>
</asp:Content>
