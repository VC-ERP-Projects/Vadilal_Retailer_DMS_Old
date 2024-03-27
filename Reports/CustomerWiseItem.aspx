<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="CustomerWiseItem.aspx.cs" Inherits="Reports_CustomerWiseItem" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../Scripts/colorbox/colorbox.css" rel="stylesheet" />
    <link href="../Scripts/datatable_new/jquery.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/datatable_new/buttons.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/datatable_new/fixedColumns.bootstrap.min.css" rel="stylesheet" />

    <script src="../Scripts/datatable_new/jquery.dataTables.min.js"></script>
    <script src="../Scripts/datatable_new/dataTables.buttons.min.js"></script>
    <script src="../Scripts/datatable_new/buttons.html5.min.js"></script>
    <script src="../Scripts/datatable_new/pdfmake.min.js"></script>
    <script src="../Scripts/datatable_new/vfs_fonts.js"></script>
    <script src="../Scripts/datatable_new/jszip.min.js"></script>
    <link href="../Scripts/colorbox/colorbox.css" rel="stylesheet" />
    <script type="text/javascript" src="../Scripts/colorbox/jquery.colorbox-min.js"></script>
    <script src="../Scripts/datatable_new/dataTables.fixedColumns.min.js"></script>
    <style>
        table.tblDetailData.table.table-bordered.nowrap.no-footer.dataTable {
            width: 99% !important;
            margin: 0;
            table-layout: auto;
            height: 450px;
        }

        table.dataTable tbody th, table.dataTable tbody td {
            padding: 0px 3px !important;
        }

        .dataTables_scrollHeadInner {
            width: auto;
        }

        th.table-header-gradient {
            z-index: 9;
        }

        #page-content-wrapper {
            overflow: hidden;
        }

        .CustsrNo {
            width: 0px !important;
            text-align: center;
        }
        .srNo {
            width: 0px !important;
            text-align: center;
        }
        .ItemCode {
            width: 10px !important;
        }

        .ItemName {
            width: 70px !important;
        }

        .ExItemName {
            width: 120px !important;
        }

        .UOM {
            width: 0px !important;
        }

        .Include {
            width: 0px !important;
        }

        .SyncDate {
            width: 0px !important;
            text-align: center;
        }

        .updateDateDist {
            width: 30px !important;
            text-align: center;
        }

        .CustomerCode {
            width: 8px !important;
        }

        .CustomerName {
            width: 80px !important;
        }

        .CustGroup {
            width: 25px !important;
        }

        .Region {
            width: 20px !important;
        }

        .CustCity {
            width: 15px !important;
        }

        .Active {
            width: 5px !important;
            text-align: center;
        }

        .DisItemCode {
            width: 30px !important;
        }

        .ItemGroup {
            width: 50px !important;
        }

        .ItemDesc {
            width: 350px !important;
        }

        .FromDate {
            width: 20px !important;
            text-align: center;
        }
        
        .DistFromDate {
            width: 30px !important;
            text-align: center;
        }
        .DistRemarks {
            width: 160px !important;
        }

        .DisSrNo {
            width: 0px !important;
            text-align: center;
        }

        .DisActive {
            width: 33px !important;
            text-align: center;
        }

        .UpdateDate {
            width: 70px !important;
            text-align: center;
        }
    </style>
    <script type="text/javascript">
        var ParentID = '<% = ParentID%>';
        var CustType = '<% =CustType%>';
        var Version = '<% = Version%>';
        var IpAddress;
        var imagebase64 = "";
        //var LogoURL = '../Images/LOGO.png';
        var LogoURL = '../Images/CompanyLogo/<% = LogoURL%>';
        $(document).ready(function () {
            SelectOptions();
            $('.tblDetailData').hide();
        });
        $(function () {
            $("#hdnIPAdd").val(IpAddress);
            ToDataURL(LogoURL, function (dataUrl) {
                imagebase64 = dataUrl;
            })
            //Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });
        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            sender.set_contextKey("0-0-2,3,4");
        }
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

        function Clearsub(txt) {
            const CustCode = $('.txtCustCode').val();
            if ($.fn.DataTable.isDataTable('.tblDetailData')) {
                $('.tblDetailData').DataTable().destroy();
            }
            $('.tblDetailData tbody').empty();

            $.ajax({
                url: 'CustomerWiseItem.aspx/GetCustomerItemDetails',
                type: 'POST',
                dataType: 'json',
                async: false,
                contentType: 'application/json; charset=utf-8',
                data: JSON.stringify({ strCustCode: CustCode }),
                contentType: 'application/json',
                success: function (result) {
                    $.unblockUI();
                    //$('.tblDetailData tbody').empty();

                    if (result.d[0] == "") {
                        event.preventDefault();
                        return false;
                    }
                    else if (result.d[0].indexOf("ERROR=") >= 0) {
                        $('.tblDetailData').hide();

                        var ErrorMsg = result.d[0].split('=')[1].trim();
                        ModelMsg(ErrorMsg, 3);
                        event.preventDefault();
                        $('.txtPriceGroup').val();
                        $('.txtDistributor').val();
                        return false;
                    }
                    else {
                        $('.tblDetailData').show();
                        $('.tblDetailData tbody').empty();
                        var ReportData = JSON.parse(result.d[0]);
                        $('.txtPriceGroup').val(ReportData[0].PriceGroup);
                        $('.txtDistributor').val(ReportData[0].DistributorName);
                        var str = "";
                        for (var i = 0; i < ReportData.length; i++) {

                            str = "<tr><td>" + (i + 1) + "</td>"
                                    + "<td>" + ReportData[i].ItemCode + "</td>"
                                    + "<td>" + ReportData[i].ItemName + "</td>"
                                    + "<td>" + ReportData[i].UnitName + "</td>"
                                     + "<td>" + $.datepicker.formatDate('dd-M-yy', new Date(ReportData[i].StartDate)) + "</td>"
                                      + "<td>" + $.datepicker.formatDate('dd-M-yy', new Date(ReportData[i].EndDate)) + "</td>"
                                    + "<td>" + ReportData[i].IncludeExclude + "</td>"
                                    + "<td>" + ReportData[i].SyncDateTime + "</td></tr>"
                            $('.tblDetailData > tbody').append(str);
                        }
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    $.unblockUI();
                    $('.txtPriceGroup').val();
                    $('.txtDistributor').val();
                    alert('Something is wrong...' + XMLHttpRequest.responseText);
                    event.preventDefault();
                    return false;
                }
            });
            if ($('.tblDetailData tbody tr').length > 0) {
                $('.divtblData').show();
                var aryJSONColTable = [];
                aryJSONColTable.push({ "className": "CustsrNo", "aTargets": 0 });
                aryJSONColTable.push({ "className": "ItemCode", "aTargets": 1 });
                aryJSONColTable.push({ "className": "ItemName", "aTargets": 2 });
                aryJSONColTable.push({ "className": "UOM", "aTargets": 3 });
                aryJSONColTable.push({ "className": "SyncDate", "aTargets": 4 });
                aryJSONColTable.push({ "className": "SyncDate", "aTargets": 5 });

                aryJSONColTable.push({ "className": "Include", "aTargets": 6 });
                aryJSONColTable.push({ "className": "SyncDate", "aTargets": 7 });
                $(".tblDetailData").DataTable({
                    'bSort': false,
                    bFilter: true,
                    scrollCollapse: false,
                    "stripeClasses": ['odd-row', 'even-row'],
                    destroy: true,
                    scrollY: '58vh',
                    scrollX: true,
                    responsive: true,
                    dom: 'Bfrtip',
                    "bPaginate": false,
                    "bSort": false,
                    "aoColumnDefs": aryJSONColTable,
                    buttons: [{ extend: 'copy', footer: true },
                      {
                          extend: 'csv',
                          footer: true,
                          filename: 'Include / Exclude List',
                          customize: function (csv) {
                              // var data = 'Include / Exclude List' + '\n';
                              var data = 'Option,' + $('.ddlOption option:selected').text() + '\n';
                              data += 'Customer,' + ($('.txtCustCode').length > 0 && $('.txtCustCode').val() != "" ? $('.txtCustCode').val().split('-')[0].trim() + " # " + $('.txtCustCode').val().split('-')[1].trim() : "All") + '\n';
                              data += 'Price Group,' + ($('.txtPriceGroup').length > 0 && $('.txtPriceGroup').val() != "" ? $('.txtPriceGroup').val() : "All") + '\n';
                              data += 'Distributor,' + ($('.txtDistributor').length > 0 && $('.txtDistributor').val() != "" ? $('.txtDistributor').val() : "All") + '\n';
                              data += 'UserId,' + $('.hdnUserName').val() + '\n';
                              data += 'Created on,\'' + new Date().format('dd-MMM-yy HH:mm') + '\n';
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
                          filename: 'Include / Exclude List',
                          customize: function (xlsx) {

                              sheet = ExportXLS(xlsx, 7);
                              //  var r0 = Addrow(1, [{ key: 'A', value: 'Include / Exclude List' }]);
                              var r1 = Addrow(1, [{ key: 'A', value: 'Option' }, { key: 'B', value: $('.ddlOption option:selected').text() }]);
                              var r3 = Addrow(2, [{ key: 'A', value: 'Customer' }, { key: 'B', value: (($('.txtCustCode').length > 0 && $('.txtCustCode').val() != "") ? $('.txtCustCode').val().split('-')[0].trim() + " # " + $('.txtCustCode').val().split('-')[1].trim() : "All") }]);
                              var r4 = Addrow(3, [{ key: 'A', value: 'Price Group' }, { key: 'B', value: (($('.txtPriceGroup').length > 0 && $('.txtPriceGroup').val() != "") ? $('.txtPriceGroup').val() : "All") }]);
                              var r5 = Addrow(4, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistributor').length > 0 && $('.txtDistributor').val() != "") ? $('.txtDistributor').val() : "All") }]);
                              var r8 = Addrow(5, [{ key: 'A', value: 'UserId' }, { key: 'B', value: $('.hdnUserName').val() }]);
                              var r9 = Addrow(6, [{ key: 'A', value: 'Created on' }, { key: 'B', value: '\'' + (new Date().format('dd-MMM-yy HH:mm')) }]);
                              sheet.childNodes[0].childNodes[1].innerHTML = r1 + r3 + r4 + r5 + r8 + r9 + sheet.childNodes[0].childNodes[1].innerHTML;
                          }
                      },
                      {
                          extend: 'pdfHtml5',
                          orientation: 'portrait', //landscape
                          pageSize: 'A4', //A3 , A5 , A6 , legal , letter
                          title: 'Include / Exclude List',
                          footer: 'false',
                          exportOptions: {
                              columns: ':visible',
                              search: 'applied',
                              order: 'applied'
                          },
                          customize: function (doc) {
                              doc.content.splice(0, 1);
                              var now = new Date();
                              doc.pageMargins = [20, 80, 20, 30];
                              doc.defaultStyle.fontSize = 5;
                              doc.styles.tableHeader.fontSize = 6;
                              doc.styles.tableFooter.fontSize = 6;
                              doc['header'] = (function () {
                                  return {
                                      columns: [
                                          {
                                              alignment: 'left',
                                              italics: false,
                                              //text: [{ text: $("#lnkTitle").text() + "\n" },
                                              text: [{ text: ('Option : ' + $('.ddlOption option:selected').text() + '\n') },
                                                   { text: ('Customer : ' + (($('.txtCustCode').length > 0 && $('.txtCustCode').val() != "") ? $('.txtCustCode').val().split('-')[0].trim() + " # " + $('.txtCustCode').val().split('-')[1].trim() + "\n" : "All\n")) },
                                                   { text: ('Price Group : ' + (($('.txtPriceGroup').length > 0 && $('.txtPriceGroup').val() != "") ? $('.txtPriceGroup').val() + "\n" : "All\n")) },
                                                   { text: ('Distributor : ' + (($('.txtDistributor').length > 0 && $('.txtDistributor').val() != "") ? $('.txtDistributor').val() + "\n" : "All\n")) },
                                              ],

                                              fontSize: 10,
                                              height: 500,
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
                                                       text: ['Created on: ', { text: new Date().format('dd-MMM-yy HH:mm') }]
                                                   },
                                                   {
                                                       alignment: 'right',
                                                       fontSize: 8,
                                                       text: ['UserId : ', { text: $('.hdnUserName').val() }]
                                                   },
                                                   {
                                                       alignment: 'right',
                                                       fontSize: 8,
                                                       text: ['IP Address: ', { text: $("#hdnIPAdd").val() }]
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
                                  doc.content[0].table.body[i][5].alignment = 'center';
                                  doc.content[0].table.body[i][7].alignment = 'center';
                              };
                              doc.content[0].table.body[0][0].alignment = 'center';
                              doc.content[0].table.body[0][1].alignment = 'left';
                              doc.content[0].table.body[0][2].alignment = 'left';
                              doc.content[0].table.body[0][3].alignment = 'left';
                              doc.content[0].table.body[0][4].alignment = 'left';
                              doc.content[0].table.body[0][5].alignment = 'left';
                              doc.content[0].table.body[0][6].alignment = 'left';
                              doc.content[0].table.body[0][7].alignment = 'center';
                          }
                      }
                    ]
                });
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


        }
        function SelectOptions() {
            $('.txtCustCode').val('');
            $('.txtDistributor').val('');
            $('.txtPriceGroup').val('');
            var OptionId = $('.ddlOption').val();
            if (OptionId == 1) {
                $('.btnSearch').hide();
                $('.divSubDistributor').hide();
                $('.tblDetailData').hide();
                $('.divtblData').hide();
                $('.divItem').hide();
                $('.txtcustomer').show();
                $('.txtdivDistributor').show();
                $('.txtdivpricegroup').show();
            }
            else if (OptionId == 2) {
                $('.btnSearch').show();
                $('.divSubDistributor').hide();
                $('.tblDetailData').hide();
                $('.divtblData').hide();
                $('.divItem').hide();
                $('.txtcustomer').hide();
                $('.txtdivDistributor').hide();
                $('.txtdivpricegroup').hide();
            }
            else {
                $('.btnSearch').show();
                $('.divSubDistributor').hide();
                $('.tblDetailData').hide();
                $('.divItem').hide();
                $('.divtblData').hide();
                $('.tblitem').hide();
                $('.txtcustomer').hide();
                $('.txtdivDistributor').hide();
                $('.txtdivpricegroup').hide();
            }
        }
        function GetReport() {


            ClearControls();
            var OptionId = $('.ddlOption').val();
            $('.tblSubDistributor tbody').empty();
            $('.tblitem tbody').empty();
            $.ajax({
                url: 'CustomerWiseItem.aspx/LoadReport',
                type: 'POST',
                dataType: 'json',
                async: false,
                contentType: 'application/json; charset=utf-8',
                data: "{ 'OptionId': '" + OptionId + "'}",
                success: function (result) {
                    if (result.d[0] == "" || result.d[0] == undefined) {
                        return false;
                    }
                    else if (result.d[0].indexOf("ERROR=") >= 0) {
                        var ErrorMsg = result.d[0].split('=')[1].trim();
                        ModelMsg(ErrorMsg, 3);
                        $("input[name='AutoCustCode']", this).val() == "";
                        return false;
                    }
                    else {

                        var ReportData = JSON.parse(result.d[0]);
                        var str = "";
                        if (OptionId == 2) {
                            for (var i = 0; i < ReportData.length; i++) {

                                str = "<tr><td>" + (i + 1) + "</td>"
                                        + "<td>" + ReportData[i].CustomerCode + "</td>"
                                        + "<td>" + ReportData[i].CustomerName + "</td>"
                                        + "<td>" + ReportData[i].CityName + "</td>"
                                        + "<td>" + ReportData[i].Region + "</td>"
                                        + "<td>" + ReportData[i].CustGroup + "</td>"
                                        + "<td>" + $.datepicker.formatDate('dd-M-yy', new Date(ReportData[i].FromDate)) + "</td>"
                                          + "<td>" + $.datepicker.formatDate('dd-M-yy', new Date(ReportData[i].ToDate)) + "</td>"
                                            + "<td>" + ReportData[i].Remarks + "</td>"
                                        + "<td>" + ReportData[i].UpdatedDate + "</td> </tr>"
                                //+ "<td>" + ReportData[i].Employee + "</td>
                                $('.tblSubDistributor > tbody').append(str);
                            }
                        }
                        else {
                            for (var i = 0; i < ReportData.length; i++) {
                                str = "<tr><td>" + (i + 1) + "</td>"
                                        + "<td>" + ReportData[i].ItemGroupName + "</td>"
                                        + "<td>" + ReportData[i].ItemCode + "</td>"
                                        + "<td>" + ReportData[i].ItemName + "</td>"
                                        + "<td>" + ReportData[i].Remarks + "</td>"
                                        + "<td>" + $.datepicker.formatDate('dd-M-yy', new Date(ReportData[i].FromDate)) + "</td>"
                                           + "<td>" + $.datepicker.formatDate('dd-M-yy', new Date(ReportData[i].ToDate)) + "</td>"
                                       + "<td>" + ReportData[i].UpdatedDate + "</td></tr>"
                                $('.tblitem > tbody').append(str);
                            }
                        }

                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    alert('Something is wrong...' + XMLHttpRequest.responseText);
                    return false;
                }
            });
            if (OptionId == 2) {
                if ($('.tblSubDistributor tbody tr').length > 0) {
                    $('.divSubDistributor').show();
                    $('.tblSubDistributor').show();
                    $('.tblitem').hide();
                    $('.divItem').hide();

                    var now = new Date();
                    Date.prototype.today = function () {
                        return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
                    }

                    var jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: false });

                    var aryJSONColTable = [];

                    aryJSONColTable.push({ "sClass": "dtbodyCenter srNo", "aTargets": 0 });
                    aryJSONColTable.push({ "className": "CustomerCode", "aTargets": 1 });
                    aryJSONColTable.push({ "className": "CustomerName", "aTargets": 2 });
                    aryJSONColTable.push({ "className": "CustCity", "aTargets": 3 });
                    aryJSONColTable.push({ "className": "Region", "aTargets": 4 });
                    aryJSONColTable.push({ "className": "CustGroup", "aTargets": 5 });
                    aryJSONColTable.push({ "className": "FromDate", "aTargets": 6 });
                    aryJSONColTable.push({ "className": "FromDate", "aTargets": 7 });
                    aryJSONColTable.push({ "className": "DistRemarks", "aTargets": 8 });
                    aryJSONColTable.push({ "sClass": "updateDateDist", "aTargets": 9 });


                    $('.tblSubDistributor').DataTable({
                        bFilter: true,
                        scrollCollapse: true,
                        "stripeClasses": ['odd-row', 'even-row'],
                        destroy: true,
                        scrollY: '58vh',
                        scrollX: true,
                        responsive: true,
                        dom: 'Bfrtip',
                        "bPaginate": false,
                        "bSort": false,
                        "aoColumnDefs": aryJSONColTable,
                        "order": [[0, "asc"]],
                        buttons: [{ extend: 'copy', footer: true },
                           {
                               extend: 'csv', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                               customize: function (csv) {
                                   // var data = $("#lnkTitle").text() + '\n';
                                   var data = 'Option,' + $('.ddlOption option:selected').text() + '\n';
                                   data += 'UserId,' + $('.hdnUserName').val() + '\n';
                                   data += 'Created on,' + jsDate.toString() + '\n';
                                   return data + csv;
                               },
                               exportOptions: {
                                   format: {
                                       body: function (data, row, column, node) {
                                           //check if type is input using jquery
                                           return (data == "&nbsp;" || data == "") ? " " : data;
                                           var D = data;
                                       },
                                       footer: function (data, row, column, node) {
                                           //check if type is input using jquery
                                           return (data == "&nbsp;" || data == "") ? " " : data;
                                           var D = data;
                                       }
                                   }
                               }
                           },
                           {
                               extend: 'excel', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString() + '_' + new Date().toLocaleTimeString('en-US'),
                               customize: function (xlsx) {

                                   sheet = ExportXLS(xlsx, 3);

                                   //var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text() }]);
                                   var r1 = Addrow(1, [{ key: 'A', value: 'Option' }, { key: 'B', value: $('.ddlOption option:selected').text() }]);
                                   var r4 = Addrow(2, [{ key: 'A', value: 'UserId' }, { key: 'B', value: $('.hdnUserName').val() }]);
                                   var r5 = Addrow(3, [{ key: 'A', value: 'Created on' }, { key: 'B', value: jsDate.toString() }]);
                                   sheet.childNodes[0].childNodes[1].innerHTML = r1 + r4 + r5 + sheet.childNodes[0].childNodes[1].innerHTML;
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
                                   doc.styles.tableHeader.fontSize = 8;
                                   doc.styles.tableFooter.fontSize = 6;
                                   doc['header'] = (function () {
                                       return {
                                           columns: [
                                               {
                                                   alignment: 'left',
                                                   italics: false,
                                                   text: [
                                                      // { text: $("#lnkTitle").text() + '\n' },
                                                       { text: 'Option : ' + $('.ddlOption option:selected').text() + "\n" },
                                                       { text: 'User Name : ' + $('.hdnUserName').val() + "\n" },
                                                         { text: 'Created On : ' + jsDate.toString() + "\n" },
                                                   ],
                                                   fontSize: 10,
                                                   height: 350,
                                               },
                                               {
                                                   alignment: 'right',
                                                   width: 70,
                                                   height: 45,
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
                                                  text: ['Created on: ', { text: jsDate.toString() }]
                                              },
                                                {
                                                    alignment: 'right',
                                                    fontSize: 8,
                                                    text: ['UserId : ', { text: $('.hdnUserName').val() }]
                                                },
                                                {
                                                    alignment: 'right',
                                                    fontSize: 8,
                                                    text: ['IP Address: ', { text: $("#hdnIPAdd").val() }]
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
                                       doc.content[0].table.body[i][2].alignment = 'left';
                                       doc.content[0].table.body[i][3].alignment = 'left';
                                       doc.content[0].table.body[i][4].alignment = 'left';
                                       doc.content[0].table.body[i][5].alignment = 'left';
                                       doc.content[0].table.body[i][6].alignment = 'center';
                                       doc.content[0].table.body[i][7].alignment = 'center';
                                       doc.content[0].table.body[i][8].alignment = 'left';
                                       doc.content[0].table.body[i][9].alignment = 'center';
                                   };
                                   doc.content[0].table.body[0][0].alignment = 'center';
                                   doc.content[0].table.body[0][1].alignment = 'left';
                                   doc.content[0].table.body[0][2].alignment = 'left';
                                   doc.content[0].table.body[0][3].alignment = 'left';
                                   doc.content[0].table.body[0][4].alignment = 'left';
                                   doc.content[0].table.body[0][5].alignment = 'left';
                                   doc.content[0].table.body[0][6].alignment = 'center';
                                   doc.content[0].table.body[0][7].alignment = 'center';
                                   doc.content[0].table.body[0][8].alignment = 'left';
                                   doc.content[0].table.body[0][9].alignment = 'center';
                               }
                           }]
                    });
                }
            }
            else {
                if ($('.tblitem tbody tr').length > 0) {

                    $('.divSubDistributor').hide();
                    $('.tblSubDistributor').hide();
                    $('.tblitem').show();
                    $('.divItem').show();

                    var now = new Date();
                    Date.prototype.today = function () {
                        return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
                    }

                    var jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: false });

                    var aryJSONColTable = [];

                    aryJSONColTable.push({ "sClass": "DisSrNo", "aTargets": 0 });
                    aryJSONColTable.push({ "sClass": "ItemGroup", "aTargets": 1 });
                    aryJSONColTable.push({ "sClass": "DisItemCode", "aTargets": 2 });
                    aryJSONColTable.push({ "sClass": "ExItemName", "aTargets": 3 });
                    aryJSONColTable.push({ "sClass": "ItemDesc", "aTargets": 4 });
                    aryJSONColTable.push({ "sClass": "DistFromDate", "aTargets": 5 });
                    aryJSONColTable.push({ "sClass": "DistFromDate", "aTargets": 6 });
                    aryJSONColTable.push({ "sClass": "UpdateDate", "aTargets": 7 });

                    $('.tblitem').DataTable({
                        bFilter: true,
                        scrollCollapse: true,
                        "stripeClasses": ['odd-row', 'even-row'],
                        destroy: true,
                        scrollY: '58vh',
                        scrollX: true,
                        responsive: true,
                        dom: 'Bfrtip',
                        "bPaginate": false,
                        "bSort": false,
                        "aoColumnDefs": aryJSONColTable,
                        "order": [[0, "asc"]],
                        buttons: [{ extend: 'copy', footer: true },
                           {
                               extend: 'csv', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                               customize: function (csv) {
                                   // var data = $("#lnkTitle").text() + '\n';
                                   var data = 'Option,' + $('.ddlOption option:selected').text() + '\n';
                                   data += 'UserId,' + $('.hdnUserName').val() + '\n';
                                   data += 'Created on,' + jsDate.toString() + '\n';
                                   return data + csv;
                               },
                               exportOptions: {
                                   format: {
                                       body: function (data, row, column, node) {
                                           //check if type is input using jquery
                                           return (data == "&nbsp;" || data == "") ? " " : data;
                                           var D = data;
                                       },
                                       footer: function (data, row, column, node) {
                                           //check if type is input using jquery
                                           return (data == "&nbsp;" || data == "") ? " " : data;
                                           var D = data;
                                       }
                                   }
                               }
                           },
                           {
                               extend: 'excel', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString() + '_' + new Date().toLocaleTimeString('en-US'),
                               customize: function (xlsx) {

                                   sheet = ExportXLS(xlsx, 3);

                                   //  var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text() }]);
                                   var r1 = Addrow(1, [{ key: 'A', value: 'Option' }, { key: 'B', value: $('.ddlOption option:selected').text() }]);
                                   var r4 = Addrow(2, [{ key: 'A', value: 'UserId' }, { key: 'B', value: $('.hdnUserName').val() }]);
                                   var r5 = Addrow(3, [{ key: 'A', value: 'Created on' }, { key: 'B', value: jsDate.toString() }]);
                                   sheet.childNodes[0].childNodes[1].innerHTML = r1 + r4 + r5 + sheet.childNodes[0].childNodes[1].innerHTML;
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
                                   doc.styles.tableHeader.fontSize = 8;
                                   doc.styles.tableFooter.fontSize = 6;
                                   doc['header'] = (function () {
                                       return {
                                           columns: [
                                               {
                                                   alignment: 'left',
                                                   italics: false,
                                                   text: [
                                                       //{ text: $("#lnkTitle").text() + '\n' },
                                                       { text: 'Option : ' + $('.ddlOption option:selected').text() + "\n" },
                                                       { text: 'User Name : ' + $('.hdnUserName').val() + "\n" },
                                                         { text: 'Created On : ' + jsDate.toString() + "\n" },
                                                   ],
                                                   fontSize: 10,
                                                   height: 350,
                                               },
                                               {
                                                   alignment: 'right',
                                                   width: 70,
                                                   height: 45,
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
                                                  text: ['Created on: ', { text: jsDate.toString() }]
                                              },
                                                {
                                                    alignment: 'right',
                                                    fontSize: 8,
                                                    text: ['UserId : ', { text: $('.hdnUserName').val() }]
                                                },
                                                {
                                                    alignment: 'right',
                                                    fontSize: 8,
                                                    text: ['IP Address: ', { text: $("#hdnIPAdd").val() }]
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
                                       doc.content[0].table.body[i][2].alignment = 'left';
                                       doc.content[0].table.body[i][3].alignment = 'left';
                                       doc.content[0].table.body[i][4].alignment = 'left';
                                       doc.content[0].table.body[i][5].alignment = 'center';
                                       doc.content[0].table.body[i][6].alignment = 'center';
                                       doc.content[0].table.body[i][7].alignment = 'center';
                                   };
                                   doc.content[0].table.body[0][0].alignment = 'center';
                                   doc.content[0].table.body[0][1].alignment = 'left';
                                   doc.content[0].table.body[0][2].alignment = 'left';
                                   doc.content[0].table.body[0][3].alignment = 'left';
                                   doc.content[0].table.body[0][4].alignment = 'left';
                                   doc.content[0].table.body[0][5].alignment = 'center';
                                   doc.content[0].table.body[0][6].alignment = 'center';
                                   doc.content[0].table.body[0][7].alignment = 'center';
                               }
                           }]
                    });
                }
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

        function ClearControls() {

            //$('.divCustEntry').attr('style', 'display:none;');
            //$('.divScanningReport').attr('style', 'display:none;');
            //$('.divMissData').attr('style', 'display:none;');
            //$('.btnSubmit').attr('style', 'display:none;');
            //$('.btnSearch').attr('style', 'display:none;');
            //$('.divViewDetail').attr('style', 'display:none;');
            //$('#tblCustomer tbody').empty();

            //if ($.fn.DataTable.isDataTable('.gvScanningTypeHistory')) {
            //    $('.gvScanningTypeHistory').DataTable().destroy();
            //}

            //$('.gvScanningTypeHistory tbody').empty();
            //if ($('.chkIsReport').find('input').is(':checked')) {
            //    $('.divScanningReport').removeAttr('style');
            //    $('.btnSearch').removeAttr('style');
            //    $('.divViewDetail').removeAttr('style');
            //}
            //else {
            //    $('.divCustEntry').removeAttr('style');
            //    $('.btnSubmit').removeAttr('style');

            //    $('#CountRowCustomer').val(0);
            //   // FillData();
            //}
        }

        function Cancel() {
            window.location = "../Reports/CustomerWiseItem.aspx";
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <label class="input-group-addon">Option</label>
                        <asp:DropDownList runat="server" ID="ddlOption" CssClass="ddlOption form-control" TabIndex="1" onchange="SelectOptions();">
                            <asp:ListItem Value="1">Customer Wise Product</asp:ListItem>
                            <%--<asp:ListItem Value="2">Sub-Distributor for Exclude Discount</asp:ListItem>
                            <asp:ListItem Value="3">Exclude Item for Discount</asp:ListItem>--%>
                        </asp:DropDownList>
                    </div>
                </div>

                <div class="col-lg-4 txtcustomer">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCustomer" runat="server" Text="Code" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCustCode" onchange="return Clearsub(this);" runat="server" TabIndex="1" CssClass="txtCustCode form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required" Style="background-color: rgb(250, 255, 189);" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetCustomerByTypeTempState" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCustCode" BehaviorID="CustCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 txtdivDistributor">
                    <div class="input-group form-group">
                        <asp:Label ID="lblDistributor" runat="server" Text='Distributor' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDistributor" CssClass=" txtDistributor form-control" runat="server" TabIndex="3" ReadOnly="true"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-8 txtdivpricegroup">
                    <div class="input-group form-group">
                        <asp:Label ID="lblRegion" runat="server" Text='Pricing Group' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtPriceGroup" CssClass="txtPriceGroup form-control" runat="server" TabIndex="2" ReadOnly="true"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-2">
                    <div class="input-group form-group">
                        <input type="button" id="btnSearch" name="btnSearch" value="Process" tabindex="6" class="btnSearch btn btn-default" onclick="GetReport();" />
                        &nbsp
                        <input type="button" id="btnCancel" name="btnCancel" value="Cancel" tabindex="7" onclick="Cancel()" class="btn btn-default" />
                    </div>
                </div>
                <input type="hidden" class="hdnUserName" id="hdnUserName" runat="server" />
                <div id="divtblData" class="divtblData" style="max-height: 50vh;">
                    <table id="tblDetailData" class="tblDetailData table table-bordered" style="width: 99%; font-size: 11px;">
                        <thead>
                            <tr class="table-header-gradient">
                                <th style="width: 5px;">Sr.</th>
                                <th>Item Code</th>
                                <th>Item Name</th>
                                <th>UOM</th>
                                <th>From Date</th>
                                <th>To Date</th>
                                <th>Include</th>
                                <th>Synced Date/Time</th>
                            </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </div>
                <div id="divSubDistributor" class="divSubDistributor" style="max-height: 50vh;">
                    <table id="tblSubDistributor" class="tblSubDistributor table table-bordered" style="width: 99%; font-size: 11px;">
                        <thead>
                            <tr class="table-header-gradient">
                                <th style="width: 5px;">Sr.</th>
                                <th>Customer Code</th>
                                <th>Customer Name</th>
                                <th>City</th>
                                <th>Region</th>
                                <th>Customer Group</th>
                                <th>From Date</th>
                                <th>To Date</th>
                                <th>Remarks</th>
                                <th>Update Date/Time</th>
                            </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </div>
                <div id="divItem" class="divItem" style="max-height: 50vh;">
                    <table id="tblitem" class="tblitem table table-bordered" style="width: 99%; font-size: 11px;">
                        <thead>
                            <tr class="table-header-gradient">
                                <th style="width: 5px;">Sr.</th>
                                <th>Item Group</th>
                                <th>Item Code </th>
                                <th>Item Name </th>
                                <th>Description</th>
                                <th>From Date</th>
                                <th>To Date</th>
                               
                                <th>Update Date/Time</th>
                            </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

</asp:Content>

