<%@ Page Title="" Language="C#" MasterPageFile="~/ReportMaster.master" AutoEventWireup="true" CodeFile="SecondorySalesDump.aspx.cs" Inherits="Reports_SecondorySalesDump" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" Runat="Server">
     <link href="../Scripts/datatable_new/jquery.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/datatable_new/buttons.dataTables.min.css" rel="stylesheet" />

    <script src="../Scripts/datatable_new/jquery.dataTables.min.js"></script>
    <script src="../Scripts/datatable_new/dataTables.buttons.min.js"></script>
    <script src="../Scripts/datatable_new/buttons.html5.min.js"></script>
    <script src="../Scripts/datatable_new/pdfmake.min.js"></script>
    <script src="../Scripts/datatable_new/vfs_fonts.js"></script>
    <script src="../Scripts/datatable_new/jszip.min.js"></script>
    <script type="text/javascript">

        var CustType = <% = CustType%>;
        var ParentID = <% = ParentID%>;
        var Version = '<% = Version%>';
        var IpAddress;
        var imagebase64 = "";
        //var LogoURL = '../Images/LOGO.png';
        var LogoURL = '../Images/CompanyLogo/<% = LogoURL%>';
        function ClearOtherConfig() {
            if ($(".txtCode").length > 0) {
                $(".txtDistCode").val('');
                $(".txtSSDistCode").val('');
                $(".txtDealerCode").val('');
            }
        }
        
        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            var ss = "";
            if (CustType == 4)
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : ParentID;
            else
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : "0";
            sender.set_contextKey("0" + "-0-" + "0" + "-" + ss + "-" + EmpID);
        }
        
        function acetxtDealerCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            var ss = "";
            var dist = "";
            if (CustType == 4)
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : ParentID;
            else
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : "0";
            if (CustType == 2)
                dist = $('.txtDistCode').is(":visible") ? $('.txtDistCode').val().split('-').pop() : ParentID;
            else
                dist = $('.txtDistCode').is(":visible") ? $('.txtDistCode').val().split('-').pop() : "0";
            sender.set_contextKey("0" + "-0-" + "0" + "-" + ss + "-" + dist + "-" + EmpID);
        }

        function autoCompleteSSDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey("0" + "-0-" + "0" + "-" + EmpID);
        }

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
            ChangeReportFor('1');
            ToDataURL(LogoURL, function (dataUrl) {
                imagebase64 = dataUrl;
            })
            
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function getUserIP(onNewIP) { //  onNewIp - your listener function for new IPs
            //compatibility for firefox and chrome
            var myPeerConnection = window.RTCPeerConnection || window.mozRTCPeerConnection || window.webkitRTCPeerConnection;
            var pc = new myPeerConnection({
                iceServers: []
            }),
            noop = function () { },
            localIPs = {},
            ipRegex = /([0-9]{1,3}(\.[0-9]{1,3}){3}|[a-f0-9]{1,4}(:[a-f0-9]{1,4}){7})/g,
            key;

            function iterateIP(ip) {
                if (!localIPs[ip]) onNewIP(ip);
                localIPs[ip] = true;
            }

            //create a bogus data channel
            pc.createDataChannel("");

            // create offer and set local description
            pc.createOffer(function (sdp) {
                sdp.sdp.split('\n').forEach(function (line) {
                    if (line.indexOf('candidate') < 0) return;
                    line.match(ipRegex).forEach(iterateIP);
                });

                pc.setLocalDescription(sdp, noop, noop);
            }, noop);

            //listen for candidate events
            pc.onicecandidate = function (ice) {
                if (!ice || !ice.candidate || !ice.candidate.candidate || !ice.candidate.candidate.match(ipRegex)) return;
                ice.candidate.candidate.match(ipRegex).forEach(iterateIP);
            };
        }
        // Usage
        getUserIP(function (ip) {
            if (IpAddress == undefined)
                IpAddress = ip;
            try {
                if ($("#hdnIPAdd").val() == 0 || $("#hdnIPAdd").val() == "" || $("#hdnIPAdd").val() == undefined) {
                    $("#hdnIPAdd").val(ip);
                }
            }
            catch (err) {

            }
        });
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
        function ChangeReportFor(SelType) {
            if ($('.ddlSaleBy').val() == "4") {
                if (SelType == "2") {
                    $('.txtSSDistCode').val('');
                    $('.txtDistCode').val('');
                    $('.txtDealerCode').val('');
                }
                $('.divSS').removeAttr('style');
                $('.divDealer').attr('style', 'display:none;');
            }
            else if ($('.ddlSaleBy').val() == "2") {
                if (SelType == "2") {
                    $('.txtSSDistCode').val('');
                    $('.txtDistCode').val('');
                    $('.txtDealerCode').val('');
                }
                $('.divSS').attr('style', 'display:none;');
                $('.divDealer').removeAttr('style');
            }
        }

        function _btnCheck() {
            var IsValid = true;
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            IsValid = $('._masterForm').data('bootstrapValidator').isValid();
            return IsValid;
        }
            
        function EndRequestHandler2(sender, args) {
            ChangeReportFor('1');
        }

        function GETDATA() {
            $('.dx-overlay-modal').show();
            var FromDate = $(".fromdate").val();
            var ToDate = $(".todate").val();
             
            load(0);

            $.ajax({
                type: "POST",
                url: "SalesRegister.aspx/GetData",
                dataType: "json",
                data: "{ 'FromDate': '" + FromDate + "','ToDate' : '"+ToDate+"','SSDistCode' : '"+($(".txtSSDistCode").val()!=''?$(".txtSSDistCode").val().replace('\'',''):'')+"','DistCode' : '"+($(".txtDistCode").val()!=''?$(".txtDistCode").val().replace('\'',''):'')+"','DealerCode' : '"+($(".txtDealerCode").val()!=''?$(".txtDealerCode").val().replace('\'',''):'')+"','EmpCode' : '"+($(".txtCode").val()!=''?$(".txtCode").val().replace('\'',''):'')+"','ddlDocType' : '"+$('.ddlDocType option:selected').val()+"','ddlInvoiceType' : '"+$('.ddlInvoiceType option:selected').val()+"','ddlSaleBy' : '"+$('.ddlSaleBy option:selected').val()+"'}",
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
                        FillGrid(result.d.Data1);
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
                    autoExpandAll: true
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
                rowAlternationEnabled: false,
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
                    var rowCount = 12 ;
                    DevExpress.excelExporter.exportDataGrid({
                        component: e.component,
                        worksheet: worksheet,
                        keepColumnWidths: false,
                        autoFilterEnabled: false,
                        topLeftCell: { row: rowCount, column: 1 },
                        customizeCell: function (options) {
                            var gridCell = options.gridCell;
                            var excelCell = options.excelCell;
                            //if (gridCell.rowType === "header") {
                            //    gridCell.horizontalAlignment = 'left';
                            //}
                            if (gridCell.rowType === "data") {
                                excelCell.alignment = { horizontal: 'left' };
                                if (gridCell.column.dataField === 'GrossAmount'||gridCell.column.dataField === 'Discount'||gridCell.column.dataField === 'TotalValue'||gridCell.column.dataField === 'Tax'||
                                    gridCell.column.dataField === 'CST'||gridCell.column.dataField === 'AddVAT'||gridCell.column.dataField === 'Surcharge'
                                    ||gridCell.column.dataField === 'VAT'||gridCell.column.dataField === 'CGST'||gridCell.column.dataField === 'IGST'||gridCell.column.dataField === 'SGST'
                                    ||gridCell.column.dataField === 'UGST'||gridCell.column.dataField === 'TotalTax'||gridCell.column.dataField === 'NetAmount') {
                                    excelCell.value = parseFloat(gridCell.value);
                                    excelCell.alignment = { horizontal: 'right' };
                                }
                                if (gridCell.column.dataField === 'Quantity') {
                                    excelCell.value = parseInt(gridCell.value);
                                    excelCell.alignment = { horizontal: 'right' };
                                }
                                if (gridCell.column.dataField === 'Tax') {
                                    excelCell.value =  gridCell.value;
                                    excelCell.alignment = { horizontal: 'right' };
                                }
                            }
                            if (gridCell.rowType === 'group') {
                                //excelCell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: '#e3e7ff' } };
                                if (gridCell.column.dataField === 'GrossAmount'||gridCell.column.dataField === 'Discount'||gridCell.column.dataField === 'TotalValue'||
                                    gridCell.column.dataField === 'CST'||gridCell.column.dataField === 'AddVAT'||gridCell.column.dataField === 'Surcharge'
                                    ||gridCell.column.dataField === 'VAT'||gridCell.column.dataField === 'CGST'||gridCell.column.dataField === 'IGST'||gridCell.column.dataField === 'SGST'
                                    ||gridCell.column.dataField === 'UGST'||gridCell.column.dataField === 'TotalTax'||gridCell.column.dataField === 'NetAmount') {
                                    excelCell.value = parseFloat(gridCell.groupSummaryItems[0].value);
                                    excelCell.alignment = { horizontal: 'right' };
                                }
                                if (gridCell.column.dataField === 'Quantity') {
                                    excelCell.value = parseInt(gridCell.groupSummaryItems[0].value);
                                    excelCell.alignment = { horizontal: 'right' };
                                }
                            }
                            if (gridCell.rowType === 'totalFooter') {
                                //excelCell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: '#e3e7ff' } };
                                if (gridCell.column.dataField === 'GrossAmount'||gridCell.column.dataField === 'Discount'||gridCell.column.dataField === 'TotalValue'||
                                    gridCell.column.dataField === 'CST'||gridCell.column.dataField === 'AddVAT'||gridCell.column.dataField === 'Surcharge'
                                    ||gridCell.column.dataField === 'VAT'||gridCell.column.dataField === 'CGST'||gridCell.column.dataField === 'IGST'||gridCell.column.dataField === 'SGST'
                                    ||gridCell.column.dataField === 'UGST'||gridCell.column.dataField === 'TotalTax'||gridCell.column.dataField === 'NetAmount') {
                                    excelCell.value = parseFloat(gridCell.value);
                                    excelCell.alignment = { horizontal: 'right' };
                                }
                                if (gridCell.column.dataField === 'Quantity') {
                                    excelCell.value = parseInt(gridCell.value);
                                    excelCell.alignment = { horizontal: 'right' };
                                }
                            }
                        }
                    }).then(function (cellRange) {
                        // header
                        var FromDate=convertDateStringToDate($(".fromdate").val().split("/").reverse().join("-"));
                        var ToDate=convertDateStringToDate($(".todate").val().split("/").reverse().join("-"));

                        var headerRow1 = worksheet.getRow(1);
                        var headerRow2 = worksheet.getRow(2);
                        var headerRow3 = worksheet.getRow(3);
                        var headerRow4 = worksheet.getRow(4);
                        var headerRow5 = worksheet.getRow(5);
                        var headerRow6 = worksheet.getRow(6);
                        var headerRow7 = worksheet.getRow(7);
                        var headerRow8 = worksheet.getRow(8);
                        var headerRow9 = worksheet.getRow(9);
                        var headerRow10 = worksheet.getRow(10);
                        var headerRow11 = worksheet.getRow(11);

                        headerRow1.getCell(1).value = $("#lnkTitle").text();
                        headerRow2.getCell(1).value = 'From Date' + ' : ';
                        headerRow2.getCell(2).value = FromDate;
                        headerRow3.getCell(1).value = 'To Date' + ' : ';
                        headerRow3.getCell(2).value = ToDate;
                        headerRow4.getCell(1).value = 'Sale By' + ' : ';
                        headerRow4.getCell(2).value = $('.ddlSaleBy option:selected').text();
                        if ($('.ddlSaleBy').val() == "4") {
                            headerRow5.getCell(1).value = 'Super Stockist' + ' : ';
                            headerRow5.getCell(2).value = $('.txtSSDistCode').val() != '' ? $('.txtSSDistCode').val().split('-')[0].trim() + " # " + $('.txtSSDistCode').val().split('-')[1].trim() : 'All';
                            headerRow6.getCell(1).value = 'Distributor' + ' : ';
                            headerRow6.getCell(2).value = $('.txtDistCode').val() != '' ? $('.txtDistCode').val().split('-')[0].trim() + " # " + $('.txtDistCode').val().split('-')[1].trim() : 'All';
                        }
                        if ($('.ddlSaleBy').val() == "2") {
                            headerRow5.getCell(1).value = 'Distributor' + ' : ';
                            headerRow5.getCell(2).value = $('.txtDistCode').val() != '' ? $('.txtDistCode').val().split('-')[0].trim() + " # " + $('.txtDistCode').val().split('-')[1].trim() : 'All';
                            headerRow6.getCell(1).value = 'Dealer' + ' : ';
                            headerRow6.getCell(2).value = $('.txtDealerCode').val() != '' ? $('.txtDealerCode').val().split('-')[0].trim() + " # " + $('.txtDealerCode').val().split('-')[1].trim() : 'All';
                        }
                        headerRow7.getCell(1).value = 'Group By' + ' : ';
                        headerRow7.getCell(2).value = $('.ddlInvoiceType option:selected').text();
                        headerRow8.getCell(1).value = 'Invoice Type' + ' : ';
                        headerRow8.getCell(2).value = (($('.ddlDocType').val()!=0) ? $('.ddlDocType option:Selected').text() : 'All');
                        headerRow9.getCell(1).value = 'Employee' + ' : ';
                        headerRow9.getCell(2).value = ($('.txtCode').val() != '' ? $('.txtCode').val().split('-')[0].trim() + " # " + $('.txtCode').val().split('-')[1].trim() : 'All');
                        headerRow10.getCell(1).value = 'User Name' + ' : ';
                        headerRow10.getCell(2).value = $('.hdnUserName').val();
                        headerRow11.getCell(1).value = 'Created on' + ' : ';
                        headerRow11.getCell(2).value = (new Date().format('dd-MMM-yy HH:mm'));
                    }).then(function () {
                        workbook.xlsx.writeBuffer().then(function (buffer) {
                            saveAs(new Blob([buffer], { type: 'application/octet-stream' }), $("#lnkTitle").text() + '_' + new Date().toLocaleDateString() + '.xlsx');
                        });
                    });
                    e.cancel = true;
                },
                columns: [
                     { caption: "No.", dataField: "No", alignment: "center", width: 'auto' },
                     { caption: "Parent Name",dataField: "ParentName" ,groupIndex: 0 },
                     { caption: "Inv. Type", dataField: "InvType" },
                     { caption: "Inv. No",dataField: "InvNo"},
                     { caption: "Date", dataField: "Date", dataType: "date", format: "dd-MMM-yy", alignment: "center"},
                     { caption: "Customer Code",dataField: "CustomerCode"},
                     { caption: "Customer Name",dataField: "CustomerName",},
                     { caption: "Customer Group",dataField: "CustomerGroup"},
                     { caption: "GST No.",dataField: "GSTNo"},
                     { caption: "GST State",dataField: "GSTState"},
                     { caption: "HSN Code",dataField: "HSNCode",visible: $('.ddlInvoiceType option:selected').val() == "3"},
                     { caption: "UOM",dataField: "UOM"},
                     { caption: "Material",dataField: "Material",visible: $('.ddlInvoiceType option:selected').val() == "1" },
                     { caption: "Quantity",dataField: "Quantity" , alignment: "right" },
                     { caption: "Gross Amount",dataField: "GrossAmount", alignment: "right" },
                     { caption: "Discount",dataField: "Discount", alignment: "right"},
                     { caption: "SubTotal",dataField: "TotalValue", alignment: "right"},
                     { caption: "% Tax",dataField: "Tax", alignment: "right"},
                     { caption: "CST",dataField: "CST" , alignment: "right"},
                     { caption: "AddVAT",dataField: "AddVAT", alignment: "right"  },
                     { caption: "Surcharge",dataField: "Surcharge", alignment: "right" },
                     { caption: "VAT",dataField: "VAT" , alignment: "right"},
                     { caption: "CGST",dataField: "CGST" , alignment: "right" },
                     { caption: "IGST",dataField: "IGST" , alignment: "right" },
                     { caption: "SGST",dataField: "SGST" , alignment: "right" },
                     { caption: "UGST",dataField: "UGST" , alignment: "right"},
                     { caption: "Total Tax",dataField: "TotalTax" , alignment: "right"},
                     { caption: "Net Amount",dataField: "NetAmount", alignment: "right" }
                ], 
                summary: {
                    totalItems: [
                    {
                        column: 'Quantity',
                        summaryType: 'sum',
                        displayFormat: "{0}",
                        //valueFormat: { type: 'fixedPoint', precision: 0 },
                        valueFormat: "#0.##"
                    },
                    {
                        column: 'Gross Amount',
                        summaryType: 'sum',
                        displayFormat: "{0}",                        
                        //valueFormat: { type: 'fixedPoint', precision: 2 },
                        valueFormat: "#0.##"
                    }
                    ,
                    {
                        column: 'Discount',
                        summaryType: 'sum',
                        displayFormat: "{0}",
                        //valueFormat: { type: 'fixedPoint', precision: 2 },
                        valueFormat: "#0.##"
                    },
                    {
                        column: 'TotalValue',
                        summaryType: 'sum',
                        displayFormat: "{0}",
                        //valueFormat: { type: 'fixedPoint', precision: 2 },
                        valueFormat: "#0.##"
                    },
                    {
                        column: 'CST',
                        summaryType: 'sum',
                        displayFormat: "{0}",
                        //valueFormat: { type: 'fixedPoint', precision: 2 }
                        valueFormat: "#0.##"
                    },
                    {
                        column: 'AddVAT',
                        summaryType: 'sum',
                        displayFormat: "{0}",
                        //valueFormat: { type: 'fixedPoint', precision: 2 }
                        valueFormat: "#0.##"
                    },
                    {
                        column: 'Surcharge',
                        summaryType: 'sum',
                        displayFormat: "{0}",
                        //valueFormat: { type: 'fixedPoint', precision: 2 }
                        valueFormat: "#0.##"
                    },
                    {
                        column: 'VAT',
                        summaryType: 'sum',
                        displayFormat: "{0}",
                        //valueFormat: { type: 'fixedPoint', precision: 2 }
                        valueFormat: "#0.##"
                    },
                    {
                        column: 'CGST',
                        summaryType: 'sum',
                        displayFormat: "{0}",
                        //valueFormat: { type: 'fixedPoint', precision: 2 }
                        valueFormat: "#0.##"
                    },
                    {
                        column: 'IGST',
                        summaryType: 'sum',
                        displayFormat: "{0}",
                        //valueFormat: { type: 'fixedPoint', precision: 2 }
                        valueFormat: "#0.##"
                    },
                    {
                        column: 'SGST',
                        summaryType: 'sum',
                        displayFormat: "{0}",
                        //valueFormat: { type: 'fixedPoint', precision: 2 }
                        valueFormat: "#0.##"
                    },
                    {
                        column: 'UGST',
                        summaryType: 'sum',
                        displayFormat: "{0}",
                        //valueFormat: { type: 'fixedPoint', precision: 2 }
                        valueFormat: "#0.##"
                    },
                    {
                        column: 'Total Tax',
                        summaryType: 'sum',
                        displayFormat: "{0}",
                        //valueFormat: { type: 'fixedPoint', precision: 2 }                        
                        valueFormat: "#0.##"
                    },
                    {
                        column: 'Net Amount',
                        summaryType: 'sum',
                        displayFormat: "{0}",
                        //valueFormat: { type: 'fixedPoint', precision: 2 }
                        valueFormat: "#0.##"
                    }],
                    groupItems:[{
                        column: 'Quantity',
                        summaryType: 'sum',
                        displayFormat: "{0}",
                        valueFormat: { type: 'fixedPoint', precision: 0},
                        showInGroupFooter: false,
                        alignByColumn: true,
                        valueFormat: "#0"
                    },{
                        column: 'Gross Amount',
                        summaryType: 'sum',
                        displayFormat: "{0}",
                        //valueFormat: { type: 'fixedPoint', precision: 2},
                        showInGroupFooter: false,
                        alignByColumn: true,
                        valueFormat: "#0.##"
                    },{
                        column: 'Discount',
                        summaryType: 'sum',
                        displayFormat: "{0}",
                        //valueFormat: { type: 'fixedPoint', precision: 2},
                        showInGroupFooter: false,
                        alignByColumn: true,
                        valueFormat: "#0.##"
                    },
                    {
                        column: 'TotalValue',
                        summaryType: 'sum',
                        displayFormat: "{0}",
                        //valueFormat: { type: 'fixedPoint', precision: 2},
                        showInGroupFooter: false,
                        alignByColumn: true,
                        valueFormat: "#0.##"
                    },{
                        column: 'CST',
                        summaryType: 'sum',
                        displayFormat: "{0}",
                        //valueFormat: { type: 'fixedPoint', precision: 2},
                        showInGroupFooter: false,
                        alignByColumn: true,
                        valueFormat: "#0.##"
                    },{
                        column: 'AddVAT',
                        summaryType: 'sum',
                        displayFormat: "{0}",
                        //valueFormat: { type: 'fixedPoint', precision: 2},
                        showInGroupFooter: false,
                        alignByColumn: true,
                        valueFormat: "#0.##"
                    },{
                        column: 'Surcharge',
                        summaryType: 'sum',
                        displayFormat: "{0}",
                        //valueFormat: { type: 'fixedPoint', precision: 2},
                        showInGroupFooter: false,
                        alignByColumn: true,
                        valueFormat: "#0.##"
                    },{
                        column: 'VAT',
                        summaryType: 'sum',
                        displayFormat: "{0}",
                        //valueFormat: { type: 'fixedPoint', precision: 2},
                        showInGroupFooter: false,
                        alignByColumn: true,
                        valueFormat: "#0.##"
                    },{
                        column: 'CGST',
                        summaryType: 'sum',
                        displayFormat: "{0}",
                        //valueFormat: { type: 'fixedPoint', precision: 2},
                        showInGroupFooter: false,
                        alignByColumn: true,
                        valueFormat: "#0.##"
                    },{
                        column: 'IGST',
                        summaryType: 'sum',
                        displayFormat: "{0}",
                        //valueFormat: { type: 'fixedPoint', precision: 2},
                        showInGroupFooter: false,
                        alignByColumn: true,
                        valueFormat: "#0.##"
                    },{
                        column: 'SGST',
                        summaryType: 'sum',
                        displayFormat: "{0}",
                        //valueFormat: { type: 'fixedPoint', precision: 2},
                        showInGroupFooter: false,
                        alignByColumn: true,
                        valueFormat: "#0.##"
                    },{
                        column: 'UGST',
                        summaryType: 'sum',
                        displayFormat: "{0}",
                        //valueFormat: { type: 'fixedPoint', precision: 2},
                        showInGroupFooter: false,
                        alignByColumn: true,
                        valueFormat: "#0.##"
                    },{
                        column: 'Total Tax',
                        summaryType: 'sum',
                        displayFormat: "{0}",
                        //valueFormat: { type: 'fixedPoint', precision: 2},
                        showInGroupFooter: false,
                        alignByColumn: true,
                        valueFormat: "#0.##"
                    },{
                        column: 'Net Amount',
                        summaryType: 'sum',
                        displayFormat: "{0}",
                        //valueFormat: { type: 'fixedPoint', precision: 2},
                        showInGroupFooter: false,
                        alignByColumn: true,
                        valueFormat: "#0.##"
                    }],
                },
                onContentReady: function (e) {
                    if (!collapsed) {
                        collapsed = true;
                        e.component.expandRow(["EnviroCare"]);
                    }
                    //e.element.find(".dx-datagrid-export-button").dxButton("instance").option("text", "Export To Excel");
                }
            }).dxDataGrid("instance");
            $('#exportButton').dxButton({
                icon: 'exportpdf',
                text: 'Export to PDF',
                format: "A4", landscape: true,
                onClick: function () {

                    function convertDateStringToDate(dateStr) {
                        let months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                        let date = new Date(dateStr);
                        var day = date.getDate();

                        let str = (('' + day).length < 2 ? '0' : '') + day + '-' + months[date.getMonth()] + '-' + date.getFullYear().toString().substr(-2)
                        return str;
                    }

                    const pdfDoc = new jsPDF('l', 'pt', 'a4');
                    pdfDoc.addImage(imagebase64, 752, 20, 70, 50);
                    pdfDoc.setFontSize(10);
                    const pageCount = pdfDoc.internal.getNumberOfPages();
                    var headerLeft ="";
                    var headerRight ="";
                    var footer = "" ;
                    var TotalPageNumber = 0;
                    //for (let i = 1; i <= pageCount; i++) {
                    //pdfDoc.setPage(i);
                    TotalPageNumber++ ;
                    const pageSize = pdfDoc.internal.pageSize;
                    const pageWidth = pageSize.width ? pageSize.width : pageSize.getWidth();
                    const pageHeight = pageSize.height ? pageSize.height : pageSize.getHeight();
                    var FromDate=convertDateStringToDate($(".fromdate").val().split("/").reverse().join("-"));
                    var ToDate=convertDateStringToDate($(".todate").val().split("/").reverse().join("-"));
                    //var headerText = $("#lnkTitle").text();
                    headerLeft = 'From Date' + ' : ' + FromDate + "\t" +
                      'To Date' + ' : ' + ToDate + "\n" +
                      'Sale By' + ' : ' + $('.ddlSaleBy option:selected').text() + "\n" +
                      (($('.ddlSaleBy').val() == "4") ? 'Super Stockist : ' + (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "") ? $('.txtSSDistCode').val().split('-').slice(0, 2) : "All") + '\n':'')+
                      'Distributor' + ' : ' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "")  ? $('.txtDistCode').val().split('-').slice(0, 2) : "All") + "\n" ;

                    headerRight =  "\n"+(($('.ddlSaleBy').val() == "2") ? 'Dealer : ' + ($('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "All") + '\n':'') +'Group By' + ' : ' + ($('.ddlInvoiceType option:Selected').text()) + "\n" +
                      'Invoice Type' + ' : ' +(($('.ddlDocType').val()!=0) ? $('.ddlDocType option:Selected').text() : 'All')  + "\n" +
                      'Employee' + ' : ' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "All") + "\n";

                    footer =  'Created on' + ' : ' + (new Date().format('dd-MMM-yy HH:mm'))+'\t\t\t'+' User Name' + ' : ' + $('.hdnUserName').val()+'\t\t\t'
                      +' IP Address' + ' : ' + $("#hdnIPAdd").val()+'\t\t\t\t' +' Version' + ' : ' + Version;
                    //+' Page '+ i +' of ' + pageCount
                    // Header
                    //pdfDoc.text(header, 20, 20, { baseline: 'top' }, { styles: { fontSize: 7 } });
                    // Footer
                    //pdfDoc.text(footer, pageWidth / 2 - (pdfDoc.getTextWidth(footer) / 2), pageHeight - 15, { baseline: 'bottom' });
                    //}
                    var totalPageCount = pdfDoc.internal.getNumberOfPages();
                    DevExpress.pdfExporter.exportDataGrid({
                        jsPDFDocument: pdfDoc,
                        component: dataGrid,
                        autoTableOptions: {
                            theme: 'grid',
                            tableWidth: 'auto',
                            showHead: 'everyPage',
                            willDrawCell: function (data) {
                                var rows = data.table.body;
                                if (data.row.index === rows.length - 1) {
                                    pdfDoc.setFillColor(45, 65, 84);
                                    pdfDoc.setTextColor(255, 255, 255);
                                }
                            },
                            //didParseCell: function (data) {
                            //    var rows = data.table.body;
                            //    if (data.row.index === rows.length - 1) {
                            //        var LastRowText = data.cell.text;
                            //        LastRowText!=""? LastRowText.toString().replace(",",""):"";
                            //        data.cell.text = '';
                            //    }
                            //},
                            //didDrawCell: function (data) {
                            //    var doc = data.doc;
                            //    var rows = data.table.body;
                            //    if (rows.length === 1) {
                            //    } else if (data.row.index === rows.length - 1) {
                            //        //doc.setFontType("bold");
                            //        pdfDoc.setFillColor(45, 65, 84,255);
                            //        pdfDoc.text(50,150,'Hello World');
                            //    }
                            //},

                            didDrawPage: function (data) {
                                //for(var i = 1; i <= totalPageCount; i++) {
                                //    // Go to page i
                                //    pdfDoc.setPage(i);
                                //    //Print Page 1 of 4 for example
                                //    //TotalPageNumber++ ;
                                //    footer = pdfDoc.text('Page ' + String(i) + ' of ' + String(pageCount),210-20,297-30,null,null,"right");
                                //}
                                // Header

                                pdfDoc.setFontSize(12);
                                pdfDoc.text($("#lnkTitle").text(), data.settings.margin.left, 22);
                                pdfDoc.setFontSize(8);
                                pdfDoc.setTextColor(40);
                                pdfDoc.text(headerLeft, data.settings.margin.left, 35);
                                //pdfDoc.text(headerRight, data.settings.margin.right, 22);
                                pdfDoc.text(pdfDoc.internal.pageSize.width - 500,20,headerRight);

                                pdfDoc.addImage(imagebase64, 752, 20, 70, 50);

                                // Footer
                                var str = "Page " + pdfDoc.internal.getNumberOfPages();


                                // jsPDF 1.4+ uses getWidth, <1.4 uses .width
                                var pageSize = pdfDoc.internal.pageSize;
                                var pageHeight = pageSize.height
                                  ? pageSize.height
                                  : pageSize.getHeight();
                                pdfDoc.text(footer+' \t\t\t\t\t'+str, data.settings.margin.left, pageHeight - 10);
                            },
                            columnStyles: {
                                0: { cellWidth: 'auto' },
                                1: { cellWidth: 30 },
                                4: { cellWidth: 40 },
                                5: { cellWidth: 70 },
                                6: { cellWidth: 35 },
                                7: { cellWidth: 'auto' },
                                8: { cellWidth: 40 },
                                9: { cellWidth: 'auto' },
                                10: { cellWidth: 'auto' },
                                12: { cellWidth: 35 },
                            },
                            styles: {
                                fontSize: 6,
                                cellWidth: 'wrap',
                                valign: 'middle',
                                halign: 'center',
                                overflow: 'linebreak',
                                cellPadding: 2,
                                overflowColumns: 'linebreak'
                            },
                            alternateRowStyles: {
                                fillColor: [243, 243, 243]
                            },
                            headStyles: {
                                fillColor: [45, 65, 84],
                                textColor: [255, 255, 255],
                                fontStyle: 'bold',
                                fontSize: 6
                            }, 
                            footStyles: {
                                fillColor: [45, 65, 84],
                                textColor: [255, 255, 255],
                                fontStyle: 'bold',
                                fontSize: 6
                            },
                            margin: { left: 20, top: 70, right: 20, bottom: 25 },
                        }
                    }).then(function () {
                        pdfDoc.save($("#lnkTitle").text() + '_' + new Date().toLocaleDateString());
                    });
                }
            });
        }

        function ExportToExcelLabel() {
            $('.dx-datagrid-export-button .dx-button-content .dx-icon-export-excel-button').each(function () {
                $(this).after($('<span class="dx-button-text">').text("Export To Excel"));
            });
            $('.dx-datagrid-export-button').addClass('dx-button-has-text');
        }
        function autoCompleteState_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey(EmpID);
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
    </script>
    <style>
        table.dataTable tbody tr.odd-row {
            background-color: #e3e7ff;
        }

        table.dataTable tbody tr.even-row {
            background-color: #fff;
        }

        .dataTables_scroll {
            overflow: auto;
        }

        .dtbodyCenter {
            text-align: center;
        }

        .dtbodyRight {
            text-align: right;
        }

        div.dataTables_wrapper {
            margin: 0 auto;
        }

        table.dataTable tbody th, table.dataTable tbody td, table.dataTable thead th, table.dataTable thead td, table.dataTable tfoot th, table.dataTable tfoot td {
            padding: 3px;
        }

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

        #gridContainer .dx-datagrid-rowsview .dx-row.dx-group-row:not(.dx-row-focused) {
            background: #e3e7ff;
            color: #000;
        }

        #gridContainer .dx-datagrid-rowsview .dx-row {
            background: #f7f7f7;
        }

        #gridContainer .dx-datagrid-summary-item {
            color: #000;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" Runat="Server">
      <asp:HiddenField runat="server" ID="hdnIPAdd" ClientIDMode="Static" Value="0" />
    <div class="loadpanel"></div>
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromDate" runat="server" Text="From Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromDate" TabIndex="1" runat="server" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="fromdate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtToDate" runat="server" TabIndex="2" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="todate form-control"></asp:TextBox>
                    </div>
                </div>
                 <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblGroupBy" runat="server" Text="Invoice Type" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlDocType" TabIndex="3" CssClass="ddlDocType form-control">
                            <asp:ListItem Text="Sales Invoice" Value="1" />
                            <asp:ListItem Text="Sales Return" Value="2" />
                            <asp:ListItem Text="Both" Value="0" Selected="True" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4" id="divEmpCode" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" OnChange="ClearOtherConfig()" runat="server" CssClass="form-control txtCode" Style="background-color: rgb(250, 255, 189);" TabIndex="5"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4" id="divRegion" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblRegion" runat="server" Text='Region' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtRegion" CssClass="txtRegion form-control" TabIndex="6" runat="server" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender1" runat="server"
                            ServiceMethod="GetStatesCurrHierarchy" ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1"
                            TargetControlID="txtRegion" UseContextKey="True" OnClientPopulating="autoCompleteState_OnClientPopulating">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                
                <div class="col-lg-4" style="display:none;">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblSaleBy" Text="Sale By" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlSaleBy" TabIndex="4" CssClass="ddlSaleBy form-control" onchange="ChangeReportFor('2');">
                            <asp:ListItem Text="Super Stockist" Value="4" />
                            <asp:ListItem Text="Distributor" Value="2" Selected="True" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4 divSS" id="divSS" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblSSCustomer" runat="server" Text="Super Stockist" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtSSDistCode" runat="server" TabIndex="5" Style="background-color: rgb(250, 255, 189);" CssClass="txtSSDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="aceSStxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetSSCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteSSDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtSSDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divDistributor" id="divDistributor" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDistCode" runat="server" TabIndex="7" Style="background-color: rgb(250, 255, 189);" CssClass="txtDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDistCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divDealer" id="divDealer" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lbldealer" runat="server" Text="Dealer" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDealerCode" runat="server" TabIndex="8" Style="background-color: rgb(250, 255, 189);" CssClass="txtDealerCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtDealerCode" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDealerFromCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="acetxtDealerCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDealerCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                
                
                <div class="col-lg-4" style="display: none">
                    <div class="input-group form-group">
                        <asp:Label ID="lblData" runat="server" Text="GST # City" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtData" runat="server" CssClass="txtData form-control" Enabled="false"></asp:TextBox>
                    </div>
                </div>

                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <input type="hidden" class="hdnUserName" id="hdnUserName" runat="server" />
                        <asp:Button ID="btnGenerat" runat="server" Text="Generate" TabIndex="9" CssClass="btn btn-default" OnClientClick="return _btnCheck();" OnClick="btnGenerat_Click" />
                        <%--<input type="button" id="btnSubmit" name="Go" value="Go" class="btnSubmit btn btn-default" onclick="GETDATA();" tabindex="21" />--%>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12">
                    <%--<asp:GridView ID="gvSalesRegister" runat="server" CssClass="gvSalesRegister table" Style="font-size: 11px;" Width="100%"
                        OnPreRender="gvSalesRegister_PreRender" ShowFooter="True" ShowHeader="true" HeaderStyle-CssClass=" table-header-gradient" FooterStyle-CssClass=" table-header-gradient"
                        EmptyDataText="No data found. ">
                    </asp:GridView>--%>
                    <div class="demo-container">
                        <div id="exportButton"></div>
                        <div id="gridContainer"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>

</asp:Content>

