<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="ClaimStatus.aspx.cs" Inherits="Reports_ClaimStatus" %>

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
        var ParentID = <% = ParentID%>;
        var CustType = '<% =CustType%>';

        // Get vadilal logo
        var imagebase64 = "";
        //var LogoURL = '../Images/LOGO.png';
        var LogoURL = '../Images/CompanyLogo/<% = LogoURL%>';
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
        function ClearOtherConfig() {
            if ($(".txtCode").length > 0) {
                $(".txtDistCode").val('');
                $(".txtSSDistCode").val('');
                $(".txtRegion").val('');
                $(".txtPlant").val('');
            }
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

        function autoCompleteSSDistriCode_OnClientPopulating(sender, args) {
            var reg = $('.txtRegion').val().split('-').pop();
            var plt = $('.txtPlant').val().split('-').pop();
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            sender.set_contextKey(reg + "-0-" + plt + "-" + EmpID);
        }

        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            var reg = $('.txtRegion').val().split('-').pop();
            var plt = $('.txtPlant').val().split('-').pop();
            var ss = $('.txtSSDistCode').val().split('-').pop();
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            sender.set_contextKey(reg + "-0-" + plt + "-" + ss + "-" + EmpID);
        }

        $(function () {
            Reload();
            ChangeReportFor();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);

            // Convert vadilal logo to Base64 format
            ToDataURL(LogoURL, function (dataUrl) {
                imagebase64 = dataUrl;
            })
        });

        function EndRequestHandler2(sender, args) {
            Reload();
            ChangeReportFor();
        }

        function ChangeReportFor() {

            if ($('.ddlReportBy').val() == "4") {
                $('.txtDistCode').val('');
                $('.divSS').removeAttr('style');
                $('.divDistributor').attr('style', 'display:none;');
            }
            else if ($('.ddlReportBy').val() == "2") {
                $('.txtSSDistCode').val('');
                $('.divSS').attr('style', 'display:none;');
                $('.divDistributor').removeAttr('style');
            }
        }

        function _btnCheck() {

            var IsValid = true;

            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            IsValid = $('._masterForm').data('bootstrapValidator').isValid();
            return IsValid;
        }

        function CheckChange(val) {

            if ($(".ddlDate").val() == "1") {
                $('.onlymonth').removeAttr('disabled');
                $('.datepick').attr('disabled', 'disabled');
            }
            else {
                $('.datepick').removeAttr('disabled');
                $('.onlymonth').attr('disabled', 'disabled');
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

        function Reload() {
            var now = new Date();
            Date.prototype.today = function () {
                return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
            }
            var jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: true });

            $(".onlymonth").datepicker({
                dateFormat: 'mm/yy', showButtonPanel: true, changeYear: true, changeMonth: true,
                onClose: function (dateText, inst) {
                    $(this).datepicker('setDate', new Date(inst.selectedYear, inst.selectedMonth, 3));
                }
            });


            $('.fromdate').datepicker({
                numberOfMonths: 1,
                dateFormat: 'dd/mm/yy',
                changeMonth: true,
                changeYear: true,
                minDate: new Date(2014, 1, 1),
                onSelect: function (selected) {
                    $('.todate').datepicker("option", "minDate", selected); 
                    $(this).change();
                }
            });

            $('.todate').datepicker({
                numberOfMonths: 1,
                dateFormat: 'dd/mm/yy',
                changeMonth: true,
                changeYear: true,
                minDate: new Date(2014, 1, 1),
                onSelect: function (selected) {
                    $('.fromdate').datepicker("option", "maxDate", selected);
                    $(this).change();
                }
            });

            $(".onlymonth").on('focus blur click', function () {
                $(".ui-datepicker-calendar").hide();

            });

            if ($('.gvclaimstatus thead tr').length > 0) {

                var table = $(".gvclaimstatus").DataTable();
                var colCount = table.columns()[0].length;

                var aryJSONColTable = [];

                aryJSONColTable.push({ "width": "14px","sClass": "dtbodyRight", "aTargets": 0 });
                aryJSONColTable.push({ "width": "62px","sClass": "dtbodyleft", "aTargets": 1 });
                aryJSONColTable.push({ "width": "190px","sClass": "dtbodyleft", "aTargets": 2 });
                aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyleft", "aTargets": 3 });
                aryJSONColTable.push({ "width": "130px","sClass": "dtbodyleft", "aTargets": 4 });
                aryJSONColTable.push({ "width": "170px","sClass": "dtbodyleft", "aTargets": 5 });
                aryJSONColTable.push({ "width": "150px", "sClass": "dtbodyleft", "aTargets": 6 });
                aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyRight", "aTargets": 7 });
                aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyCenter", "aTargets": 8 });
                aryJSONColTable.push({ "width": "80px", "sClass": "dtbodyRight", "aTargets": 9 });
                aryJSONColTable.push({ "width": "90px", "sClass": "dtbodyRight", "aTargets": 10 });
                aryJSONColTable.push({ "width": "100px",  "sClass": "dtbodyleft", "aTargets": 11 });
                aryJSONColTable.push({ "width": "50px",  "sClass": "dtbodyCenter", "aTargets": 12 });
                aryJSONColTable.push({ "width": "65px",  "sClass": "dtbodyleft", "aTargets": 13 });
                aryJSONColTable.push({ "width": "60px",  "sClass": "dtbodyCenter", "aTargets": 14 });
                aryJSONColTable.push({ "width": "38px",  "sClass": "dtbodyleft", "aTargets": 15 });
                aryJSONColTable.push({ "width": "60px", "sClass": "dtbodyleft", "aTargets": 16 });
                $('.gvclaimstatus').DataTable(
                                       {
                        bFilter: true,
                        "stripeClasses": ['odd-row', 'even-row'],
                        scrollCollapse: true,
                        destroy: true,
                        "sExtends": "collection",
                        scrollY: '55vh',
                        scrollX: false,
                        responsive: true,
                        dom: 'Bfrtip',
                        "bPaginate": false,
                        "bSort": false,
                        "order": [[0, "asc"]],
                        "aoColumnDefs": aryJSONColTable,
                        "autoWidth": false,
                                           buttons: [{ extend: 'copy', footer: true },
                                            {
                                                extend: 'csv', footer: true, filename: 'ClaimStatus_' + new Date().toLocaleDateString(),
                                                customize: function (csv) {
                                                    var data = 'Claim Status Report \n';
                                                    data += 'Date Option,' + $('.ddlDate option:Selected').text() + '\n';
                                                    data += 'Date From,' + ($('.fromdate').val()) +" " + 'To Date' + ($('.todate').val()) + '\n';
                                                    data += 'Report For,' + $('.ddlReportBy option:selected').text() + '\n';
                                                    data += 'Employee,' + (($('.txtCode').length > 0 && $('.txtCode').val() != "" && $('.txtCode').val().split('-').length > 1) ? $('.txtCode').val().split('-')[0] + "#" + $('.txtCode').val().split('-')[1] : "All") + '\n';
                                                    data += 'Region,' + (($('.txtRegion').length > 0 && $('.txtRegion').val() != "" && $('.txtRegion').val().split('-').length > 1) ? $('.txtRegion').val().split('-')[0]+"#"+$('.txtRegion').val().split('-')[1] : "All") + '\n';
                                                    data += 'Plant,' + (($('.txtPlant').length > 0 && $('.txtPlant').val() != "" && $('.txtPlant').val().split('-').length > 1) ? $('.txtPlant').val().split('-')[0] +"#" + $('.txtPlant').val().split('-')[1] : "All") + '\n';
                                                    if($('.ddlReportBy option:selected').val() == '2')
                                                    {
                                                        data += 'Distributor Code & Name,' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "" && $('.txtDistCode').val().split('-').length > 1) ? $('.txtDistCode').val().split('-')[0]+"#"+$('.txtDistCode').val().split('-')[1]: "All") + '\n';
                                                    }
                                                    else
                                                    {
                                                        data += 'Super Stockist Code & Name,' + (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "" && $('.txtSSDistCode').val().split('-').length > 1) ? $('.txtSSDistCode').val().split('-')[0] +"#"+$('.txtSSDistCode').val().split('-')[1]: "All") + '\n';
                                                    }
                                                    data += 'Claim Status,' + (($('.ddlClaimStatus').val() != 0) ? $('.ddlClaimStatus option:Selected').text() : "All")+ '\n';
                                                    data += 'Claim Type,' + (($('.ddlMode option:Selected').val()) != 0 ? $('.ddlMode option:Selected').text() : "All" )+ '\n';
                                                    data += 'Auto/Manual,' +(($('.ddlIsAuto option:Selected').val()) != 2 ? $('.ddlIsAuto option:Selected').text() : "All") + '\n';
                                                    data += 'User Name,' + $('.hdnUserName').val() + '\n';
                                                    data += 'Created on,' + jsDate.toString() + '\n\n';

                                                    return data + csv;
                                                },
                                                exportOptions: {
                                                    format: {
                                                        body: function (data, row, column, node) {
                                                            //check if type is input using jquery
                                                            return (data == "&nbsp;" || data == "" || data.indexOf("/[^a-zA-Z0-9_\.,\-_ !\(\)]/g") > -1) ? " " : data;
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
                                                extend: 'excel', footer: true, filename: 'ClaimStatus_' + new Date().toLocaleDateString(),
                                                customize: function (xlsx) {

                                                    sheet = ExportXLS(xlsx, 13);

                                                    var r0 = Addrow(1, [{ key: 'A', value: 'Claim Status Report' }]);
                                                    var r1 = Addrow(2, [{ key: 'A', value: 'Date Option' }, { key: 'B', value: $('.ddlDate option:Selected').text() }]);
                                                    var r2 = Addrow(3, [{ key: 'A', value: 'Date From' }, { key: 'B', value: ($('.fromdate').val()) }, { key: 'C', value: 'To Date'},{key: 'D', value: ($('.todate').val())}]);
                                                    var r3 = Addrow(4, [{ key: 'A', value: 'Report For' }, { key: 'B', value: $('.ddlReportBy option:selected').text() }]);
                                                    var r4 = Addrow(5, [{ key: 'A', value: 'Employee' }, { key: 'B', value: (($('.txtCode').length > 0 && $('.txtCode').val() != "" && $('.txtCode').val().split('-').length > 1) ? $('.txtCode').val().split('-')[0]+"#"+$('.txtCode').val().split('-')[1] : "All") }]);
                                                    var r5 = Addrow(6, [{ key: 'A', value: 'Region' }, { key: 'B', value: (($('.txtRegion').length > 0 && $('.txtRegion').val() != "" && $('.txtRegion').val().split('-').length > 1) ? $('.txtRegion').val().split('-')[0] +"#"+$('.txtRegion').val().split('-')[1] : "All") }]);
                                                    var r6 = Addrow(7, [{ key: 'A', value: 'Plant' }, { key: 'B', value: (($('.txtPlant').length > 0 && $('.txtPlant').val() != "" && $('.txtPlant').val().split('-').length > 1) ? $('.txtPlant').val().split('-')[0]+"#"+$('.txtPlant').val().split('-')[1] : "All") }]);
                                                    if($('.ddlReportBy option:selected').val() == '2')
                                                    {
                                                        var r7 = Addrow(8, [{ key: 'A', value: 'Distributor Code & Name' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "" && $('.txtDistCode').val().split('-').length > 1) ? $('.txtDistCode').val().split('-')[0] +"#"+$('.txtDistCode').val().split('-')[1] : "All") }]);
                                                    }
                                                    else
                                                    {
                                                        var r7 = Addrow(8, [{ key: 'A', value: 'Super Stockist Code & Name' }, { key: 'B', value: (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "" && $('.txtSSDistCode').val().split('-').length > 1) ? $('.txtSSDistCode').val().split('-')[0]+"#"+$('.txtSSDistCode').val().split('-')[1] : "All") }]);
                                                    }
                                                    var r8 = Addrow(9, [{ key: 'A', value: 'Claim Status' }, { key: 'B', value: ($('.ddlClaimStatus option:Selected').val() != 0 ? $('.ddlClaimStatus option:Selected').text() : "All") }]);
                                                    var r9 = Addrow(10, [{ key: 'A', value: 'Claim Type' }, { key: 'B', value: ($('.ddlMode option:Selected').val() != 0 ? $('.ddlMode option:Selected').text(): "All") }]);
                                                    var r10 = Addrow(11, [{ key: 'A', value: 'Auto/Manual' }, { key: 'B', value: ($('.ddlIsAuto option:Selected').val() != 2 ? $('.ddlIsAuto option:Selected').text() : "All") }]);
                                                    var r11 = Addrow(12, [{ key: 'A', value: 'User Name' }, { key: 'B', value: ($('.hdnUserName').val()) }]);
                                                    var r12 = Addrow(13, [{ key: 'A', value: 'Created on' }, { key: 'B', value: (jsDate.toString()) }]);
                                                    sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r3 + r4 + r5 + r6 + r7 + r8 + r9 + r10 + r11 + r12 + sheet.childNodes[0].childNodes[1].innerHTML;
                                                }
                                            },
                                            {
                                                extend: 'pdfHtml5',
                                                orientation: 'landscape',
                                                pageSize: 'A4', //A3 , A5 , A6 , legal , letter
                                                title: 'Claim Status Report',
                                                footer : 'true',
                                                exportOptions: {
                                                    columns: ':visible',
                                                    search: 'applied',
                                                    order: 'applied'
                                                },
                                                customize: function (doc) {
                                                    doc.content.splice(0, 1);
                                                    //doc.content.splice(0, 1, {
                                                    //    margin: [0, -80, 0, 0], // [Left,Top,Bottom,Right]
                                                    //    alignment: 'right',
                                                    //    width: 70,
                                                    //    height: 60,
                                                    //    image: imagebase64
                                                    //});
                                                    var now = new Date();
                                                    Date.prototype.today = function () {
                                                        return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
                                                    }
                                                    var jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: true });

                                                    doc.pageMargins = [15, 140, 15, 40];
                                                    //doc['content']['0'].table.widths = ['1%', '6%', '9%', '3%', '9%', '11%', '7%', '6%', '5%', '7%', '7%','10%', '5%', '6%', '5%', '3%'];
                                                    doc.defaultStyle.fontSize = 7;
                                                    doc.styles.tableHeader.fontSize = 7;
                                                    doc.styles.tableFooter.fontSize = 7;
                                                    doc['header'] = (function () {
                                                        return {
                                                            columns: [
                                                                {
                                                                    alignment: 'left',
                                                                    italics: false,
                                                                    text: [{ text: 'Claim Status Report'  + "\n" },
                                                                        { text: 'Date Option : ' + ($('.ddlDate option:Selected').text().indexOf("Select") > -1 ? " All " : $('.ddlDate option:Selected').text()) + "\n" },
                                                                        { text: 'Date From : ' + $('.fromdate').val() + '\t To Date : ' + $('.todate').val() + "\n" },
                                                                        { text: 'Report For : ' + (($('.ddlReportBy option:Selected').text().indexOf("Select") > -1 ? " All " : $('.ddlReportBy option:Selected').text()) + "\n") }, 
                                                                        { text: 'Employee : ' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-')[0]+"#"+$('.txtCode').val().split('-')[1] + "\n" : "All\n") },
                                                                        { text: 'Region : ' + (($('.txtRegion').length > 0 && $('.txtRegion').val() != "") ? $('.txtRegion').val().split('-')[0]+"#"+$('.txtRegion').val().split('-')[1] + "\n" : "All\n") },
                                                                        { text: 'Plant : ' + (($('.txtPlant').length > 0 && $('.txtPlant').val() != "") ? $('.txtPlant').val().split('-')[0]+"#"+$('.txtPlant').val().split('-')[1] + "\n" : "All\n") },
                                                        
                                                                        { text: ($('.ddlReportBy option:Selected').val() == '2') ? ('Distributor Code & Name : ' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-')[0]+"#"+$('.txtDistCode').val().split('-')[1] + "\n" : "All\n"))
                                                                                : ('Super Stockist Code & Name : ' + (($('.txtSSDistCode').length > 0 && $('.txtSSDistCode').val() != "") ? $('.txtSSDistCode').val().split('-')[0]+"#"+$('.txtSSDistCode').val().split('-')[1] + "\n" : "All\n")) },
                                                                      
                                                                        { text: 'Claim Status : ' + ($('.ddlClaimStatus option:Selected').text().indexOf("Select") > -1 ? " All " : $('.ddlClaimStatus option:Selected').text()) + "\n" }, 
                                                                        { text: 'Claim Type : ' + ($('.ddlMode option:Selected').text().indexOf("Select") > -1 ? " All " : $('.ddlMode option:Selected').text()) + "\n" }, 
                                                                        { text: 'Auto/Manual : ' + ($('.ddlIsAuto option:Selected').text().indexOf("All") > -1 ? " All " : $('.ddlIsAuto option:Selected').text()) + "\n" },
                                                                        { text: 'User Name : ' + ($('.hdnUserName').val()) + "\n" }],
                                                                    fontSize: 8,
                                                                    height: 700,
                                                                }
                                                                //,
                                                                //{
                                                                //    fontSize: 14,
                                                                //    text: 'Claim Status Report',
                                                                //    height: 700,
                                                                //},
                                                                //{
                                                                //    alignment: 'right',
                                                                //    //margin: [0, -100, 0, 20], // [Left,Top,Bottom,Right]
                                                                //    width: 70,
                                                                //    height: 50,
                                                                //    image: imagebase64
                                                                //}
                                                            ],
                                                            margin: [20, 20]
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
                                                        doc.content[0].table.body[i][0].alignment = 'center';
                                                        doc.content[0].table.body[i][1].alignment = 'left';
                                                        doc.content[0].table.body[i][2].alignment = 'left';
                                                        doc.content[0].table.body[i][3].alignment = 'left';
                                                        doc.content[0].table.body[i][4].alignment = 'left';
                                                        doc.content[0].table.body[i][5].alignment = 'left';
                                                        doc.content[0].table.body[i][6].alignment = 'left';
                                                        doc.content[0].table.body[i][7].alignment = 'right';
                                                        doc.content[0].table.body[i][8].alignment = 'center';
                                                        doc.content[0].table.body[i][9].alignment = 'right';
                                                        doc.content[0].table.body[i][10].alignment = 'right';
                                                        doc.content[0].table.body[i][11].alignment = 'left';
                                                        doc.content[0].table.body[i][12].alignment = 'center';
                                                        doc.content[0].table.body[i][13].alignment = 'left';
                                                        doc.content[0].table.body[i][14].alignment = 'center';
                                                        doc.content[0].table.body[i][15].alignment = 'left';
                                                        doc.content[0].table.body[i][16].alignment = 'left';
                                                    };
                                                    //Header Alignment for PDF Export.
                                                    doc.content[0].table.body[0][0].alignment = 'center';
                                                    doc.content[0].table.body[0][1].alignment = 'left';
                                                    doc.content[0].table.body[0][2].alignment = 'left';
                                                    doc.content[0].table.body[0][3].alignment = 'left';
                                                    doc.content[0].table.body[0][4].alignment = 'left';
                                                    doc.content[0].table.body[0][5].alignment = 'left';
                                                    doc.content[0].table.body[0][6].alignment = 'left';
                                                    doc.content[0].table.body[0][7].alignment = 'right';
                                                    doc.content[0].table.body[0][8].alignment = 'center';
                                                    doc.content[0].table.body[0][9].alignment = 'right';
                                                    doc.content[0].table.body[0][10].alignment = 'right';
                                                    doc.content[0].table.body[0][11].alignment = 'left';
                                                    doc.content[0].table.body[0][12].alignment = 'center';
                                                    doc.content[0].table.body[0][13].alignment = 'left';
                                                    doc.content[0].table.body[0][14].alignment = 'center';
                                                    doc.content[0].table.body[0][15].alignment = 'left';
                                                    doc.content[0].table.body[0][16].alignment = 'left';
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

                                               col9 = api.column(9,{ page: 'current'}).data().reduce(function (a, b) {
                                                   return intVal(a) + intVal(b);
                                               }, 0);

                                               col10 = api.column(10,{ page: 'current'}).data().reduce(function (a, b) {
                                                   return intVal(a) + intVal(b);
                                               }, 0);

                                               $(api.column(9).footer()).html(col9.toFixed(2));
                                               $(api.column(10).footer()).html(col10.toFixed(2));
                                           }
                                       });

            }
        }

    </script>

    <style type="text/css">
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
            /*max-height: 398px;*/
        }

        .dtbodyRight {
            text-align: right;
        }

        .dtbodyCenter {
            text-align: center;
        }

        .dtbodyleft {
            text-align: left;
        }

        table.dataTable tbody td {
            padding: 3px 10px;
        }

        table.dataTable thead th {
            padding-top: 4px;
            padding-left: 2px;
        }

        .row._masterForm.bv-form {
            margin-bottom: -10px;
        }
    </style>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblMonthWise" Text="Date Option" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlDate" CssClass="ddlDate form-control" TabIndex="1" onchange="CheckChange(this);">
                            <asp:ListItem Text="Claim Month" Value="1" Selected="True" />
                            <asp:ListItem Text="Last Claim Process" Value="2" />
                            <asp:ListItem Text="Claim Created" Value="3" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromDate" runat="server" Text="From Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromDate" runat="server" TabIndex="2" MaxLength="10"  CssClass="fromdate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtToDate" runat="server" TabIndex="3" MaxLength="10"  CssClass="todate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblReportBy" Text="Report For" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlReportBy" TabIndex="4" CssClass="ddlReportBy form-control" onchange="ChangeReportFor();">
                            <asp:ListItem Text="Super Stockist" Value="4" />
                            <asp:ListItem Text="Distributor" Value="2" Selected="True" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4" id="divEmpCode" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" OnChange="ClearOtherConfig()" runat="server" CssClass="form-control txtCode" Style="background-color: rgb(250, 255, 189);" TabIndex="5"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender3" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblRegion" runat="server" Text='Region' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtRegion" CssClass="txtRegion form-control" TabIndex="6" runat="server" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender1" runat="server" ServiceMethod="GetStatesCurrHierarchy"
                            ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" OnClientPopulating="autoCompleteState_OnClientPopulating"
                            TargetControlID="txtRegion" UseContextKey="True">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>

                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblPlant" runat="server" Text='Plant' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtPlant" runat="server" Style="background-color: rgb(250, 255, 189);" TabIndex="7" CssClass="txtPlant form-control"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender2" runat="server" ServiceMethod="GetPlantsCurrHierarchy"
                            ServicePath="../Service.asmx" OnClientPopulating="autoCompletePlant_OnClientPopulating" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtPlant" UseContextKey="True">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divSS" id="divSS" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblSSCustomer" runat="server" Text="Super Stockist" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtSSDistCode" runat="server" TabIndex="8" Style="background-color: rgb(250, 255, 189);" CssClass="txtSSDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="aceSStxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetSSCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteSSDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtSSDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divDistributor" id="divDistributor" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDistCode" runat="server" TabIndex="8" Style="background-color: rgb(250, 255, 189);" CssClass="txtDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDistCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblstatus" runat="server" Text="Claim Status" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlClaimStatus" TabIndex="9" CssClass="ddlClaimStatus form-control">
                            <asp:ListItem Text="---- Select ----" Value="0" Selected="True" />
                            <asp:ListItem Text="Pending" Value="1" />
                            <asp:ListItem Text="Error" Value="2" />
                            <asp:ListItem Text="Success" Value="3" />
                            <asp:ListItem Text="InProcess" Value="4" />
                            <asp:ListItem Text="Delete" Value="6" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblIsAuto" Text="Auto/Manual" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlIsAuto" CssClass="ddlIsAuto form-control" TabIndex="10">
                            <asp:ListItem Text="--- All ---" Value="2" Selected="True" />
                            <asp:ListItem Text="Auto Entry" Value="1" />
                            <asp:ListItem Text="Manual Entry" Value="0" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblreasoncode" Text="Claim Type" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList ID="ddlMode" runat="server" TabIndex="11" CssClass="ddlMode form-control"></asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Generate" TabIndex="12" CssClass="btn btn-default" OnClientClick="return _btnCheck();" OnClick="btnGenerat_Click" />
                        <input type="hidden" class="hdnUserName" id="hdnUserName" runat="server" />
                    </div>
                </div>
                <div class="col-lg-12">
                    <asp:GridView ID="gvclaimstatus" runat="server" CssClass="gvclaimstatus  table" Style="font-size: 10px;"
                        OnPreRender="gvclaimstatus_Prerender" AutoGenerateColumns="true"
                        HeaderStyle-CssClass=" table-header-gradient" Width="100%" ShowFooter="True" ShowHeader="true" FooterStyle-CssClass=" table-header-gradient" EmptyDataText="No data found. ">
                    </asp:GridView>
                </div>
            </div>
            <br />
        </div>
    </div>
</asp:Content>

