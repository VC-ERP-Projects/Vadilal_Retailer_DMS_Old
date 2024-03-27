<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="CompanySalesSummary.aspx.cs" Inherits="Reports_CompanySalesSummary" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../Scripts/datatable_new/jquery.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/datatable_new/buttons.dataTables.min.css" rel="stylesheet" />
    <script src="../Scripts/datatable_new/jquery.dataTables.min.js"></script>
    <script src="../Scripts/datatable_new/dataTables.buttons.min.js"></script>
    <script src="../Scripts/datatable_new/buttons.html5.min.js"></script>
    <script src="../Scripts/datatable_new/pdfmake.min.js"></script>
    <script src="../Scripts/datatable_new/vfs_fonts.js"></script>
    <script src="../Scripts/datatable_new/jszip.min.js"></script>
    <script type="text/javascript">

        var ParentID = '<% = ParentID%>';
        var CustType = '<% =CustType%>';
        var Version = '<% = Version%>';
        var IpAddress;
        var imagebase64 = "";
        //var LogoURL = '../Images/LOGO.png';
        var LogoURL = '../Images/CompanyLogo/<% = LogoURL%>';
        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            var reg = $('.txtRegion').is(":visible") ? $('.txtRegion').val().split('-').pop() : "0";
            var plt = $('.txtPlant').is(":visible") ? $('.txtPlant').val().split('-').pop() : "0";
            var ss = "";
            if (CustType == 4)
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : ParentID;
            else
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : "0";
            sender.set_contextKey(reg + "-0-" + plt + "-" + ss + "-" + EmpID);
        }

        function acetxtDealerCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            var reg = $('.txtRegion').is(":visible") ? $('.txtRegion').val().split('-').pop() : "0";
            var plt = $('.txtPlant').is(":visible") ? $('.txtPlant').val().split('-').pop() : "0";
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
            sender.set_contextKey(reg + "-0-" + plt + "-" + ss + "-" + dist + "-" + EmpID);
        }

        function autoCompleteSSDistriCode_OnClientPopulating(sender, args) {
            var reg = $('.txtRegion').val().split('-').pop();
            var plt = $('.txtPlant').val().split('-').pop();
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey(reg + "-0-" + plt + "-" + EmpID);
        }

        function autoCompletePlant_OnClientPopulating(sender, args) {
            var key = $('.txtRegion').val().split('-').pop();
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey(key + "-0" + "-" + EmpID);
        }

        function autoCompleteState_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";

            sender.set_contextKey(EmpID);
        }

        $(function () {
            Reload();
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

        function EndRequestHandler2(sender, args) {
            ChangeReportFor('1');
            Reload();
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

        var TotalBills = 0, Subtotal = 0, Tax = 0, SchemeAmount = 0, Total = 0;

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
            
            //$('.ddlSaleBy').change(function () {
            //    if ($('.ddlSaleBy').val() == 2) {
            //        $('.txtSSDistCode').val('');
            //        $('#body_divSS').hide();
            //        $('#body_divDealer').show();
            //    }
            //    else {
            //        $('.txtDealerCode').val('');
            //        $('#body_divSS').show();
            //        $('#body_divDealer').hide();
            //    }
            //}).change();

            var now = new Date();
            Date.prototype.today = function () {
                return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
            }
            var jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: true });

            if ($('.gvDistributorSummary thead tr').length > 0) {

                var table = $('.gvDistributorSummary').DataTable();
                var colCount = table.columns()[0].length;
                var aryJSONColTable = [];

                aryJSONColTable.push({ "width": "25px", "sClass": "dtbodyCenter", "aTargets": 0 });
                aryJSONColTable.push({ "width": "70px", "aTargets": 1 });
                aryJSONColTable.push({ "width": "70px", "aTargets": 2 });
                aryJSONColTable.push({ "width": "270px", "aTargets": 3 });
                aryJSONColTable.push({ "width": "40px", "sClass": "dtbodyRight", "aTargets": 4 });
                aryJSONColTable.push({ "width": "40px", "sClass": "dtbodyRight", "aTargets": 5 });
                aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyRight", "aTargets": 6 });
                aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight", "aTargets": 7 });
                aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyRight", "aTargets": 8 });
                aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyRight", "aTargets": 9 });
                aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyRight", "aTargets": 10 });
                var Division = $('.ddlDivsion option:Selected').val() == 0 ? 'ALL' : $('.ddlDivsion option:Selected').text();
                $('.gvDistributorSummary').DataTable({

                    bFilter: true,
                    scrollCollapse: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    destroy: true,
                    scrollY: '46vh',
                    scrollX: true,
                    responsive: true,
                    dom: 'Bfrtip',
                    "bPaginate": false,
                    "aoColumnDefs": aryJSONColTable,
                    buttons: [{ extend: 'copy', footer: true },
                          {
                              extend: 'csv', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                              customize: function (csv) {
                                  var data = $("#lnkTitle").text() + '\n';
                                  data += 'From Date,' + $.datepicker.formatDate('dd-M-y', $('.fromdate').datepicker('getDate')) + ',To Date,' + $.datepicker.formatDate('dd-M-y', $('.todate').datepicker('getDate')) + '\n';
                                  data += 'Region,' + (($('.txtRegion').length > 0 && $('.txtRegion').val() != "") ? $('.txtRegion').val().split('-')[1] : "") + '\n';
                                  data += 'Sale By,' + $('.ddlSaleBy option:selected').text() + '\n';
                                  if ($('.ddlSaleBy').val() == "4")
                                      data += 'Super Stockist,' + (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "") ? $('.txtSSDistCode').val().split('-').slice(0, 2) : "") + '\n';
                                  data += 'Distributor,' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") + '\n';
                                  if ($('.ddlSaleBy').val() == "2")
                                      data += 'Dealer,' + ($('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "") + '\n';
                                  data += 'Employee,' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "") + '\n';
                                  data += 'Report Type,' + $('.ddlReportType option:Selected').text() + '\n';
                                  data += 'Divsion,' + Division + '\n';
                                  data += 'Option,' + $('.ddlOption option:Selected').text() + '\n';
                                  data += 'User Name,' + $('.hdnUserName').val() + '\n';
                                  data += 'Created on,' + new Date().format('dd-MMM-yy HH:mm') + '\n';
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
                              extend: 'excel', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                              customize: function (xlsx) {

                                  sheet = ExportXLS(xlsx, 15);

                                  var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text() }]);
                                  var r1 = Addrow(2, [{ key: 'A', value: 'From Date' }, { key: 'B', value: $.datepicker.formatDate('dd-M-y', $('.fromdate').datepicker('getDate')) }, { key: 'C', value: 'To Date' }, { key: 'D', value: $.datepicker.formatDate('dd-M-y', $('.todate').datepicker('getDate')) }]);
                                  var r2 = Addrow(3, [{ key: 'A', value: 'Region' }, { key: 'B', value: (($('.txtRegion').length > 0 && $('.txtRegion').val() != "") ? $('.txtRegion').val().split('-')[1] : "") }]);
                                  var r3 = Addrow(4, [{ key: 'A', value: 'Sale By' }, { key: 'B', value: $('.ddlSaleBy option:selected').text() }]);
                                  if ($('.ddlSaleBy').val() == "4") {
                                      var r4 = Addrow(5, [{ key: 'A', value: 'Super Stockist' }, { key: 'B', value: (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "") ? $('.txtSSDistCode').val().split('-').slice(0, 2) : "") }]);
                                      var r5 = Addrow(6, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") }]);
                                  }
                                  if ($('.ddlSaleBy').val() == "2") {
                                      var r4 = Addrow(5, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") }]);
                                      var r5 = Addrow(6, [{ key: 'A', value: 'Dealer' }, { key: 'B', value: ($('.txtDealerCode').val().length > 0 && $('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "") }]);
                                  }
                                  var r6 = Addrow(7, [{ key: 'A', value: 'Employee' }, { key: 'B', value: (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "") }]);
                                  var r7 = Addrow(8, [{ key: 'A', value: 'Report Type' }, { key: 'B', value: $('.ddlReportType option:selected').text() }]);

                                  var r10 = Addrow(9, [{ key: 'A', value: 'Division' }, { key: 'B', value: $('.ddlDivsion option:Selected').val() == 0 ? 'ALL' : $('.ddlDivsion option:Selected').text() }]);
                                  var r11 = Addrow(10, [{ key: 'A', value: 'Option' }, { key: 'B', value: $('.ddlOption option:Selected').text() }]);

                                  var r8 = Addrow(11, [{ key: 'A', value: 'User Name' }, { key: 'B', value: $('.hdnUserName').val() }]);
                                  var r9 = Addrow(12, [{ key: 'A', value: 'Created on' }, { key: 'B', value: '\'' + (new Date().format('dd-MMM-yy HH:mm')) }]);
                                  sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r3 + r4 + r5 + r6 + r7 + r10 + r11 + r8 + r9 + sheet.childNodes[0].childNodes[1].innerHTML;
                              }
                          },
                          {
                              extend: 'pdfHtml5',
                              orientation: 'landscape',
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
                                  doc.pageMargins = [20, 90, 20, 40];
                                  doc.defaultStyle.fontSize = 6;
                                  doc.styles.tableHeader.fontSize = 7;
                                  doc.styles.tableFooter.fontSize = 7;
                                  doc['header'] = (function () {
                                      return {
                                          columns: [
                                              {
                                                  alignment: 'left',
                                                  italics: false,
                                                  text: [{ text: $("#lnkTitle").text() + "\n", bold: true, fontSize: 12 },
                                                         { text: 'From Date : ' + $.datepicker.formatDate('dd-M-y', $('.fromdate').datepicker('getDate')) + '\t To Date : ' + $.datepicker.formatDate('dd-M-y', $('.todate').datepicker('getDate')) + "\n" },
                                                         { text: 'Region : ' + (($('.txtRegion').length > 0 && $('.txtRegion').val() != "") ? $('.txtRegion').val().split('-')[1] + "\n" : "\n") },
                                                         { text: 'Sale By : ' + ($('.ddlSaleBy option:Selected').text() + "\n") },
                                                         { text: (($('.ddlSaleBy').val() == "4") ? 'Super Stockist : ' + (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "") ? $('.txtSSDistCode').val().split('-')[1] + "\n" : "\n") : '') },
                                                         { text: 'Distributor : ' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) + "\n" : "\n") },
                                                          { text: 'Option : ' + ($('.ddlOption option:Selected').text() + "\n") }
                                                  ],
                                                  fontSize: 9,
                                                  height: 500,
                                              },
                                              {
                                                  alignment: 'left',
                                                  italics: false,
                                                  text: [{ text: '' + "\n" },
                                                         { text: (($('.ddlSaleBy').val() == "2") ? 'Dealer : ' + (($('.txtDealerCode').val() != "") ? $('.txtDealerCode').val().split('-').slice(0, 2) + "\n" : "\n") : '') },
                                                         { text: 'Employee : ' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) + "\n" : "\n") },
                                                         { text: 'Report Type : ' + ($('.ddlReportType option:Selected').text() + "\n") },
                                                         { text: 'Division : ' + ($('.ddlDivsion option:Selected').val() == 0 ? 'ALL' + '\n' : $('.ddlDivsion option:Selected').text() + "\n") }
                                                        
                                                         //, { text: 'User Name : ' + $('.hdnUserName').val() + "\n" }
                                                  ],
                                                  fontSize: 9,
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
                                                    //{
                                                    //    alignment: 'right',
                                                    //    fontSize: 8,
                                                    //    text: ['IP Address: ', { text: $("#hdnIPAdd").val() }]
                                                    //},
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
                                  for (i = 1; i < rowCount; i++) {
                                      doc.content[0].table.body[i][0].alignment = 'center';
                                      doc.content[0].table.body[i][4].alignment = 'right';
                                      doc.content[0].table.body[i][5].alignment = 'right';
                                      doc.content[0].table.body[i][6].alignment = 'right';
                                      doc.content[0].table.body[i][7].alignment = 'right';
                                      doc.content[0].table.body[i][8].alignment = 'right';
                                      doc.content[0].table.body[i][9].alignment = 'right';
                                      doc.content[0].table.body[i][10].alignment = 'right';
                                  };
                                  doc.content[0].table.body[0][0].alignment = 'center';
                                  doc.content[0].table.body[0][1].alignment = 'left';
                                  doc.content[0].table.body[0][2].alignment = 'left';
                                  doc.content[0].table.body[0][3].alignment = 'left';
                                  doc.content[0].table.body[0][4].alignment = 'right';
                                  doc.content[0].table.body[0][5].alignment = 'right';
                                  doc.content[0].table.body[0][6].alignment = 'right';
                                  doc.content[0].table.body[0][7].alignment = 'right';
                                  doc.content[0].table.body[0][8].alignment = 'right';
                                  doc.content[0].table.body[0][9].alignment = 'right';
                                  doc.content[0].table.body[0][10].alignment = 'right';

                              }
                          }],
                    "footerCallback": function (row, data, start, end, display) {

                        var api = this.api(), data;

                        // Remove the formatting to get integer data for summation
                        var intVal = function (i) {
                            return typeof i === 'string' ?
                                i.replace(/[\$,]/g, '') * 1 :
                                typeof i === 'number' ?
                                i : 0;
                        };

                        TotalBills = api.column(4, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        TotalQty = api.column(5, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        GrossAmt = api.column(6, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        SchemeAmount = api.column(7, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        SubTotal = api.column(8, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        Tax = api.column(9, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        Total = api.column(10, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        $(api.column(4).footer()).html(TotalBills);
                        $(api.column(5).footer()).html(TotalQty);
                        $(api.column(6).footer()).html(GrossAmt.toFixed(2));
                        $(api.column(7).footer()).html(SchemeAmount.toFixed(2));
                        $(api.column(8).footer()).html(SubTotal.toFixed(2));
                        $(api.column(9).footer()).html(Tax.toFixed(2));
                        $(api.column(10).footer()).html(Total.toFixed(2));
                    }
                });
            }
            else if ($('.gvDelearSummary thead tr').length > 0) {

                var table = $('.gvDelearSummary').DataTable();
                var colCount = table.columns()[0].length;
                var aryJSONColTable = [];

                aryJSONColTable.push({ "width": "25px", "sClass": "dtbodyCenter", "aTargets": 0 });
                aryJSONColTable.push({ "width": "70px", "aTargets": 1 });
                aryJSONColTable.push({ "width": "70px", "aTargets": 2 });
                aryJSONColTable.push({ "width": "260px", "aTargets": 3 });
                aryJSONColTable.push({ "width": "100px", "aTargets": 4 });
                aryJSONColTable.push({ "width": "250px", "aTargets": 5 });
                aryJSONColTable.push({ "width": "40px", "sClass": "dtbodyRight", "aTargets": 6 });
                aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyRight", "aTargets": 7 });
                aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight", "aTargets": 8 });
                aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight", "aTargets": 9 });
                aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight", "aTargets": 10 });
                aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight", "aTargets": 11 });
                aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight", "aTargets": 12 });
                var Division = $('.ddlDivsion option:Selected').val() == 0 ? 'ALL' : $('.ddlDivsion option:Selected').text();
                $('.gvDelearSummary').DataTable({
                    bFilter: true,
                    scrollCollapse: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    destroy: true,
                    scrollY: '45vh',
                    scrollX: true,
                    responsive: true,
                    dom: 'Bfrtip',
                    "bPaginate": false,
                    "aoColumnDefs": aryJSONColTable,
                    buttons: [{ extend: 'copy', footer: true },
                          {
                              extend: 'csv', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                              customize: function (csv) {
                                  var data = $("#lnkTitle").text() + '\n';
                                  data += 'From Date,' + $.datepicker.formatDate('dd-M-y', $('.fromdate').datepicker('getDate')) + ',To Date,' + $.datepicker.formatDate('dd-M-y', $('.todate').datepicker('getDate')) + '\n';
                                  data += 'Region,' + (($('.txtRegion').length > 0 && $('.txtRegion').val() != "") ? $('.txtRegion').val().split('-')[1] : "") + '\n';
                                  data += 'Sale By,' + $('.ddlSaleBy option:selected').text() + '\n';
                                  if ($('.ddlSaleBy').val() == "4")
                                      data += 'Super Stockist,' + (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "") ? $('.txtSSDistCode').val().split('-').slice(0, 2) : "") + '\n';
                                  data += 'Distributor,' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") + '\n';
                                  if ($('.ddlSaleBy').val() == "2")
                                      data += 'Dealer,' + ($('.txtDealerCode').length > 0 && $('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "") + '\n';
                                  data += 'Employee,' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "") + '\n';
                                  data += 'Report Type,' + $('.ddlReportType option:selected').text() + '\n';
                                  data += 'Divsion,' + Division + '\n';
                                  data += 'Option,' + $('.ddlOption option:Selected').text() + '\n';
                                  data += 'User Name,' + $('.hdnUserName').val() + '\n';
                                  data += 'Created on,' + new Date().format('dd-MMM-yy HH:mm') + '\n';
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
                              extend: 'excel', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                              customize: function (xlsx) {

                                  sheet = ExportXLS(xlsx, 15);

                                  var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text() }]);
                                  var r1 = Addrow(2, [{ key: 'A', value: 'From Date' }, { key: 'B', value: $.datepicker.formatDate('dd-M-y', $('.fromdate').datepicker('getDate')) }, { key: 'C', value: 'To Date' }, { key: 'D', value: $.datepicker.formatDate('dd-M-y', $('.todate').datepicker('getDate')) }]);
                                  var r2 = Addrow(3, [{ key: 'A', value: 'Region' }, { key: 'B', value: (($('.txtRegion').length > 0 && $('.txtRegion').val() != "") ? $('.txtRegion').val().split('-')[1] : "") }]);
                                  var r3 = Addrow(4, [{ key: 'A', value: 'Sale By' }, { key: 'B', value: $('.ddlSaleBy option:selected').text() }]);
                                  if ($('.ddlSaleBy').val() == "4") {
                                      var r4 = Addrow(5, [{ key: 'A', value: 'Super Stockist' }, { key: 'B', value: (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "") ? $('.txtSSDistCode').val().split('-').slice(0, 2) : "") }]);
                                      var r5 = Addrow(6, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") }]);
                                  }
                                  if ($('.ddlSaleBy').val() == "2") {
                                      var r4 = Addrow(5, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") }]);
                                      var r5 = Addrow(6, [{ key: 'A', value: 'Dealer' }, { key: 'B', value: ($('.txtDealerCode').val().length > 0 && $('.txtDealerCode').val() != "" ? $('.txtDealerCode').val().split('-').slice(0, 2) : "") }]);
                                  }
                                  var r6 = Addrow(7, [{ key: 'A', value: 'Employee' }, { key: 'B', value: (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "") }]);
                                  var r7 = Addrow(8, [{ key: 'A', value: 'Report Type' }, { key: 'B', value: $('.ddlReportType option:selected').text() }]);

                                  var r10 = Addrow(9, [{ key: 'A', value: 'Divsion' }, { key: 'B', value: $('.ddlDivsion option:Selected').val() == 0 ? 'ALL' : $('.ddlDivsion option:Selected').text() }]);
                                  var r11 = Addrow(10, [{ key: 'A', value: 'Option' }, { key: 'B', value: $('.ddlOption option:Selected').text() }]);

                                  var r8 = Addrow(11, [{ key: 'A', value: 'User Name' }, { key: 'B', value: $('.hdnUserName').val() }]);
                                  var r9 = Addrow(12, [{ key: 'A', value: 'Created on' }, { key: 'B', value: '\'' + (new Date().format('dd-MMM-yy HH:mm')) }]);
                                  sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r3 + r4 + r5 + r6 + r7 + r10 + r11 + r8 + r9 + sheet.childNodes[0].childNodes[1].innerHTML;
                              }
                          },
                          {
                              extend: 'pdfHtml5',
                              orientation: 'landscape',
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
                                  doc.pageMargins = [20, 90, 20, 40];
                                  doc.defaultStyle.fontSize = 6;
                                  doc.styles.tableHeader.fontSize = 7;
                                  doc.styles.tableFooter.fontSize = 7;
                                  doc['header'] = (function () {
                                      return {
                                          columns: [
                                              {
                                                  alignment: 'left',
                                                  italics: false,
                                                  text: [{ text: $("#lnkTitle").text() + "\n", bold: true, fontSize: 12 },
                                                         { text: 'From Date : ' + $.datepicker.formatDate('dd-M-y', $('.fromdate').datepicker('getDate')) + '\t To Date : ' + $.datepicker.formatDate('dd-M-y', $('.todate').datepicker('getDate')) + "\n" },
                                                         { text: 'Region : ' + (($('.txtRegion').length > 0 && $('.txtRegion').val() != "") ? $('.txtRegion').val().split('-')[1] + "\n" : "\n") },
                                                         { text: 'Sale By : ' + ($('.ddlSaleBy option:Selected').text() + "\n") },
                                                         { text: (($('.ddlSaleBy').val() == "4") ? 'Super Stockist : ' + (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "") ? $('.txtSSDistCode').val().split('-')[1] + "\n" : "\n") : '') },
                                                         { text: 'Distributor : ' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-')[1] + "\n" : "\n") },
                                                        { text: 'Option : ' + ($('.ddlOption option:Selected').text() + "\n") }],

                                                  fontSize: 9,
                                                  height: 500,
                                              },
                                               {
                                                   alignment: 'left',
                                                   italics: false,
                                                   text: [{ text: '' + "\n" },
                                                       { text: (($('.ddlSaleBy').val() == "2") ? 'Dealer : ' + (($('.txtDealerCode').length > 0 && $('.txtDealerCode').val() != "") ? $('.txtDealerCode').val().split('-')[1] + "\n" : "\n") : '') },
                                                          { text: 'Employee : ' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) + "\n" : "\n") },
                                                          { text: 'Report Type : ' + ($('.ddlReportType option:Selected').text() + "\n") },
                                                            { text: 'Division : ' + ($('.ddlDivsion option:Selected').val() == 0 ? 'ALL' + "\n" : $('.ddlDivsion option:Selected').text() + "\n") }
                                                         // ,{ text: 'User Name : ' + $('.hdnUserName').val() + "\n" }
                                                   ],
                                                       fontSize: 9,
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
                                                    //{
                                                    //    alignment: 'right',
                                                    //    fontSize: 8,
                                                    //    text: ['IP Address: ', { text: $("#hdnIPAdd").val() }]
                                                    //},
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
                                  for (i = 1; i < rowCount; i++) {
                                      doc.content[0].table.body[i][0].alignment = 'center';
                                      doc.content[0].table.body[i][6].alignment = 'right';
                                      doc.content[0].table.body[i][7].alignment = 'right';
                                      doc.content[0].table.body[i][8].alignment = 'right';
                                      doc.content[0].table.body[i][9].alignment = 'right';
                                      doc.content[0].table.body[i][10].alignment = 'right';
                                      doc.content[0].table.body[i][11].alignment = 'right';
                                      doc.content[0].table.body[i][12].alignment = 'right';
                                  };
                                  doc.content[0].table.body[0][0].alignment = 'center';
                                  doc.content[0].table.body[0][1].alignment = 'left';
                                  doc.content[0].table.body[0][2].alignment = 'left';
                                  doc.content[0].table.body[0][3].alignment = 'left';
                                  doc.content[0].table.body[0][4].alignment = 'left';
                                  doc.content[0].table.body[0][5].alignment = 'left';
                                  doc.content[0].table.body[0][6].alignment = 'right';
                                  doc.content[0].table.body[0][7].alignment = 'right';
                                  doc.content[0].table.body[0][8].alignment = 'right';
                                  doc.content[0].table.body[0][9].alignment = 'right';
                                  doc.content[0].table.body[0][10].alignment = 'right';
                                  doc.content[0].table.body[0][11].alignment = 'right';
                                  doc.content[0].table.body[0][12].alignment = 'right';
                              }
                          }],
                    "footerCallback": function (row, data, start, end, display) {

                        var api = this.api(), data;

                        // Remove the formatting to get integer data for summation
                        var intVal = function (i) {
                            return typeof i === 'string' ?
                                i.replace(/[\$,]/g, '') * 1 :
                                typeof i === 'number' ?
                                i : 0;
                        };


                        TotalBills = api.column(6, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        Qty = api.column(7, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        GrossAmt = api.column(8, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        SubTotal = api.column(10, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        SchemeAmount = api.column(9, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        Tax = api.column(11, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        Total = api.column(12, { page: 'current' }).data().reduce(function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0);

                        $(api.column(6).footer()).html(TotalBills);
                        $(api.column(7).footer()).html(Qty);
                        $(api.column(8).footer()).html(GrossAmt.toFixed(2));
                        $(api.column(9).footer()).html(SchemeAmount.toFixed(2));
                        $(api.column(10).footer()).html(SubTotal.toFixed(2));
                        $(api.column(11).footer()).html(Tax.toFixed(2));
                        $(api.column(12).footer()).html(Total.toFixed(2));
                    }
                });
            }
        }

    </script>
    <style>
        div.dataTables_wrapper {
            margin: 0 auto;
        }

        table.dataTable tbody tr.odd-row {
            background-color: #e3e7ff;
        }

        table.dataTable tbody tr.even-row {
            background-color: #fff;
        }

        .dataTables_scroll {
            overflow: auto;
        }

        .dtbodyRight {
            text-align: right;
        }

        .dtbodyCenter {
            text-align: center;
        }

        table.dataTable thead th, table.dataTable thead td, table.dataTable tbody td, table.dataTable tfoot td {
            padding: 1px 14px;
        }
    </style>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">

    <div class="panel">
        <div class="panel-body _masterForm">
            <div class="row">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:label id="lblFromDate" runat="server" text="From Date" cssclass="input-group-addon"></asp:label>
                        <asp:textbox id="txtFromDate" tabindex="1" runat="server" maxlength="10" onkeyup="return ValidateDate(this);" data-bv-notempty="true" data-bv-notempty-message="Field is required" cssclass="fromdate form-control"></asp:textbox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:label id="lblToDate" runat="server" text="To Date" cssclass="input-group-addon"></asp:label>
                        <asp:textbox id="txtToDate" runat="server" tabindex="2" maxlength="10" onkeyup="return ValidateDate(this);" data-bv-notempty="true" data-bv-notempty-message="Field is required" cssclass="todate form-control"></asp:textbox>
                    </div>
                </div>
                <div class="col-lg-4" id="divEmpCode" runat="server">
                    <div class="input-group form-group">
                        <asp:label id="lblCode" runat="server" text="Employee" cssclass="input-group-addon"></asp:label>
                        <asp:textbox id="txtCode" runat="server" cssclass="form-control txtCode" style="background-color: rgb(250, 255, 189);" tabindex="3"></asp:textbox>
                        <asp:autocompleteextender onclientshown="resetPosition" completionlistcssclass="CompletionListClass" id="acettxtEmployeeCode" runat="server" servicepath="../Service.asmx"
                            usecontextkey="true" servicemethod="GetEmployeeList" minimumprefixlength="1" completioninterval="10"
                            enablecaching="false" completionsetcount="1" targetcontrolid="txtCode">
                        </asp:autocompleteextender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:label runat="server" id="lblSaleBy" text="Sale By" cssclass="input-group-addon"></asp:label>
                        <asp:dropdownlist runat="server" id="ddlSaleBy" cssclass="ddlSaleBy form-control" tabindex="4" onchange="ChangeReportFor('2');">
                            <asp:ListItem Text="Super Stockist" Value="4" />
                            <asp:ListItem Text="Distributor" Value="2" Selected="True" />
                        </asp:dropdownlist>
                    </div>
                </div>
                <div class="col-lg-4" id="divRegion" runat="server">
                    <div class="input-group form-group">
                        <asp:label id="lblRegion" runat="server" text='Region' cssclass="input-group-addon"></asp:label>
                        <asp:textbox id="txtRegion" cssclass="txtRegion form-control" runat="server" style="background-color: rgb(250, 255, 189);" autocomplete="off" tabindex="5"></asp:textbox>
                        <asp:autocompleteextender onclientshown="resetPosition" completionlistcssclass="CompletionListClass" id="AutoCompleteExtender1" runat="server" servicemethod="GetStateEmpwiseMapping"
                            servicepath="../Service.asmx" minimumprefixlength="1" completioninterval="10" enablecaching="false" completionsetcount="1" onclientpopulating="autoCompleteState_OnClientPopulating"
                            targetcontrolid="txtRegion" usecontextkey="True">
                        </asp:autocompleteextender>
                    </div>
                </div>
                <div class="col-lg-4" id="divPlant" runat="server">
                    <div class="input-group form-group">
                        <asp:label id="lblPlant" runat="server" text='Plant' cssclass="input-group-addon"></asp:label>
                        <asp:textbox id="txtPlant" runat="server" style="background-color: rgb(250, 255, 189);" cssclass="txtPlant form-control" autocomplete="off" tabindex="6"></asp:textbox>
                        <asp:autocompleteextender onclientshown="resetPosition" completionlistcssclass="CompletionListClass" id="AutoCompleteExtender2" runat="server" servicemethod="GetPlantsStoreHierarchy"
                            servicepath="../Service.asmx" onclientpopulating="autoCompletePlant_OnClientPopulating" minimumprefixlength="1" completioninterval="10"
                            enablecaching="false" completionsetcount="1" targetcontrolid="txtPlant" usecontextkey="True">
                        </asp:autocompleteextender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:label id="Label1" runat="server" text="Divsion" cssclass="input-group-addon"></asp:label>
                        <asp:dropdownlist runat="server" id="ddlDivsion" tabindex="7" cssclass="ddlDivsion form-control" datatextfield="DivisionName" datavaluefield="DivisionlID">
                            </asp:dropdownlist>
                    </div>
                </div>
                <div class="col-lg-4 divSS" id="divSS" runat="server">
                    <div class="input-group form-group">
                        <asp:label id="lblSSCustomer" runat="server" text="Super Stockist" cssclass="input-group-addon"></asp:label>
                        <asp:textbox id="txtSSDistCode" runat="server" tabindex="8" style="background-color: rgb(250, 255, 189);" cssclass="txtSSDistCode form-control" autocomplete="off"></asp:textbox>
                        <asp:autocompleteextender onclientshown="resetPosition" completionlistcssclass="CompletionListClass" id="aceSStxtName" runat="server" servicepath="~/Service.asmx"
                            usecontextkey="true" servicemethod="GetSSStoreHierarchy" minimumprefixlength="1" completioninterval="10" onclientpopulating="autoCompleteSSDistriCode_OnClientPopulating"
                            enablecaching="false" completionsetcount="1" targetcontrolid="txtSSDistCode">
                        </asp:autocompleteextender>
                    </div>
                </div>
                <div class="col-lg-4 divDistributor" id="divDistributor" runat="server">
                    <div class="input-group form-group">
                        <asp:label id="lblCustomer" runat="server" text="Distributor" cssclass="input-group-addon"></asp:label>
                        <asp:textbox id="txtDistCode" runat="server" tabindex="9" style="background-color: rgb(250, 255, 189);" cssclass="txtDistCode form-control" autocomplete="off"></asp:textbox>
                        <asp:autocompleteextender onclientshown="resetPosition" completionlistcssclass="CompletionListClass" id="acetxtName" runat="server" servicepath="~/Service.asmx"
                            usecontextkey="true" servicemethod="GetDistStoreHierarchy" minimumprefixlength="1" completioninterval="10" onclientpopulating="autoCompleteDistriCode_OnClientPopulating"
                            enablecaching="false" completionsetcount="1" targetcontrolid="txtDistCode">
                        </asp:autocompleteextender>
                    </div>
                </div>
                <div class="col-lg-4 divDealer" id="divDealer" runat="server">
                    <div class="input-group form-group">
                        <asp:label id="lbldealer" runat="server" text="Dealer" cssclass="input-group-addon"></asp:label>
                        <asp:textbox id="txtDealerCode" runat="server" tabindex="10" style="background-color: rgb(250, 255, 189);" cssclass="txtDealerCode form-control" autocomplete="off"></asp:textbox>
                        <asp:autocompleteextender onclientshown="resetPosition" completionlistcssclass="CompletionListClass" id="acetxtDealerCode" runat="server" servicepath="~/Service.asmx"
                            usecontextkey="true" servicemethod="GetDealerFromStoreHierarchy" minimumprefixlength="1" completioninterval="10" onclientpopulating="acetxtDealerCode_OnClientPopulating"
                            enablecaching="false" completionsetcount="1" targetcontrolid="txtDealerCode">
                        </asp:autocompleteextender>
                    </div>
                </div>
                <div class="col-lg-4" style="display: none">
                    <div class="input-group form-group" id="divFrAmt" runat="server">
                        <asp:label id="lblFromAmt" runat="server" text='From Amount' cssclass="input-group-addon"></asp:label>
                        <asp:textbox id="txtFromAmt" runat="server" onkeypress="return isNumberKey(event);" maxlength="10" cssclass="txtFromAmt form-control" tabindex="11"></asp:textbox>
                    </div>
                </div>
                <div class="col-lg-4" style="display: none">
                    <div class="input-group form-group" id="divToAmt" runat="server">
                        <asp:label id="lblToAmt" runat="server" text='To Amount' cssclass="input-group-addon"></asp:label>
                        <asp:textbox id="txtToAmt" runat="server" onkeypress="return isNumberKey(event);" maxlength="11" cssclass="txtToAmt form-control" tabindex="11"></asp:textbox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:label id="lblSchemeType" runat="server" text="Report Type" cssclass="input-group-addon"></asp:label>
                        <asp:dropdownlist runat="server" id="ddlReportType" tabindex="12" cssclass="ddlReportType form-control">
                            <asp:ListItem Value="0">Parent Wise</asp:ListItem>
                            <asp:ListItem Value="1">Customer Wise</asp:ListItem>
                        </asp:dropdownlist>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:label id="Label2" runat="server" text="Option" cssclass="input-group-addon"></asp:label>
                        <asp:dropdownlist runat="server" id="ddlOption" tabindex="12" cssclass="ddlOption form-control">
                            <asp:ListItem Value="0">Both</asp:ListItem>
                            <asp:ListItem Value="1">Sales</asp:ListItem>
                            <asp:ListItem Value="2">Sales Return</asp:ListItem>
                        </asp:dropdownlist>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:button id="btnGenerat" runat="server" text="Go" tabindex="13" cssclass="btn btn-default" onclick="btnGenerat_Click" />
                        &nbsp;&nbsp;&nbsp;
                        <asp:button id="btnExport" runat="server" text="Export To Excel" tabindex="13" cssclass="btn btn-default" onclick="btnExport_Click" />
                        <input type="hidden" class="hdnUserName" id="hdnUserName" runat="server" />
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12">
                    <asp:gridview id="gvDistributorSummary" runat="server" width="100%" cssclass="gvDistributorSummary table tbl" style="font-size: 11px;" onprerender="gvDistributorSummary_PreRender" headerstyle-cssclass=" table-header-gradient" footerstyle-cssclass=" table-header-gradient" showfooter="true" emptydatatext="No data found. ">
                    </asp:gridview>
                    <asp:gridview id="gvDelearSummary" runat="server" width="100%" cssclass="gvDelearSummary  table tbl" style="font-size: 11px;" onprerender="gvDelearSummary_PreRender" headerstyle-cssclass=" table-header-gradient" footerstyle-cssclass=" table-header-gradient" showfooter="true" emptydatatext="No data found. ">
                    </asp:gridview>
                </div>
            </div>
        </div>
    </div>

</asp:Content>

