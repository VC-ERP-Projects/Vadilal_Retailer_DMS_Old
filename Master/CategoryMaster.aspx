<%@ Page Title="" Language="C#" MasterPageFile="~/MainMaster.master" AutoEventWireup="true" CodeFile="CategoryMaster.aspx.cs" Inherits="Master_CategoryMaster" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../Scripts/datatable_new/jquery.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/datatable_new/buttons.dataTables.min.css" rel="stylesheet" />
    <script src="../Scripts/datatable_new/jquery.dataTables.min.js"></script>
    <script src="../Scripts/datatable_new/dataTables.buttons.min.js"></script>
    <script src="../Scripts/datatable_new/buttons.html5.min.js"></script>
    <script src="../Scripts/datatable_new/pdfmake.min.js"></script>
    <script src="../Scripts/datatable_new/vfs_fonts.js"></script>
    <script src="../Scripts/datatable_new/jszip.min.js"></script>
    <script type="text/javascript" src="../Scripts/fixHeaderFooter.js"></script>
    <script type="text/javascript">
        var availableParent = [];

        var Version = '<% = Version%>';
         var LogoURL = '../Images/LOGO.png';
         var IpAddress;

         function getUserIP(onNewIP) { //  onNewIp - your listener function for new IPs
             //compatibility for firefox and chrome
             try {
                 var myPeerConnection = window.RTCPeerConnection || window.mozRTCPeerConnection || window.webkitRTCPeerConnection;
                 var pc = new myPeerConnection({
                     iceServers: []
                 }),
                     noop = function () { },
                     localIPs = {},
                     ipRegex = /([0-9]{1,3}(\.[0-9]{1,3}){3}|[a-f0-9]{1,4}(:[a-f0-9]{1,4}){7})/g,
                     key;
             }
             catch (err) {

             }

             function iterateIP(ip) {
                 if (!localIPs[ip]) onNewIP(ip);
                 localIPs[ip] = true;
             }
             try {
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
             catch (err) {

             }
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
         function myModal() {
             $('#myCopyModal').modal();
         }
         function Relaod() {
             //  $(".gvCategory").tableHeadFixer('60.5vh');
             $(".txtACT2Search").keyup(function () {
                 var word = this.value;
                 $(".gvCategory > tbody tr").each(function () {
                     if ($(this).find("td").text().toUpperCase().indexOf(word.toUpperCase()) >= 0)
                         $(this).show();
                     else
                         $(this).hide();
                 });
             });
         }

         function hideModal() {
             $('#myCopyModal').modal('hide');
             $('.modal-backdrop').css('display', 'none');
         }

         function CloseModal() {
             // $('#endDateSeq').prop('disabled', true);
         }
         $(document).ready(function () {
             ClearControls();
             ToDataURL(LogoURL, function (dataUrl) {
                 imagebase64 = dataUrl;
             })
         });
         $(function () {
             Relaod();
             //  Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);

         });
         function GetReport() {

             if ($('.chkIsReport').find('input').is(':checked')) {
                 ClearControls();

                 $('.gvCategoryHistory tbody').empty();
                 $.ajax({
                     url: 'CategoryMaster.aspx/LoadReport',
                     type: 'POST',
                     dataType: 'json',
                     async: false,
                     contentType: 'application/json; charset=utf-8',
                     data: "{ 'strIsHistory': '" + $('.chkIsHistory').find('input').is(':checked') + "'}",
                     success: function (result) {
                         if (result.d[0] == "" || result.d[0] == undefined) {
                             return false;
                         }
                         else if (result.d[0].indexOf("ERROR=") >= 0) {
                             var ErrorMsg = result.d[0].split('=')[1].trim();
                             ModelMsg(ErrorMsg, 3);
                             return false;
                         }
                         else {
                             var ReportData = JSON.parse(result.d[0]);
                             $('.divCategoryReport').removeAttr('style');
                             var str = "";

                             for (var i = 0; i < ReportData.length; i++) {

                                 str = "<tr><td>" + ReportData[i].SRNo + "</td>"
                                         + "<td >" + ReportData[i].CategoryCode + "</td>"
                                           + "<td class='tdRegion'>" + ReportData[i].Description + "</td>"
                                         //+ "<td>" + ReportData[i].FromDate + "</td>"
                                         //+ "<td>" + ReportData[i].ToDate + "</td>"
                                         + "<td>" + ReportData[i].Active + "</td>"
                                         + "<td>" + ReportData[i].IsDeleted + "</td>"
                                         + "<td>" + ReportData[i].CreatedBy + "</td>"
                                         + "<td>" + ReportData[i].CreatedDate + "</td>"
                                         + "<td>" + ReportData[i].UpdatedBy + "</td>"
                                         + "<td>" + ReportData[i].UpdatedDate + "</td> </tr>"

                                 $('.gvCategoryHistory > tbody').append(str);
                             }
                         }
                     },
                     error: function (XMLHttpRequest, textStatus, errorThrown) {
                         alert('Something is wrong...' + XMLHttpRequest.responseText);
                         return false;
                     }
                 });

                 if ($('.gvCategoryHistory tbody tr').length > 0) {

                     var now = new Date();
                     Date.prototype.today = function () {
                         return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
                     }

                     var jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: false });

                     var aryJSONColTable = [];

                     aryJSONColTable.push({ "width": "5px", "sClass": "dtbodyCenter", "aTargets": 0 });
                     aryJSONColTable.push({ "width": "20px", "aTargets": 1 });
                     aryJSONColTable.push({ "width": "75px", "aTargets": 2 });
                     aryJSONColTable.push({ "width": "3px", "aTargets": 3 });
                     aryJSONColTable.push({ "width": "3px", "aTargets": 4 });
                     aryJSONColTable.push({ "width": "35px", "aTargets": 5 });//"sClass": "dtbodyLeft",
                     aryJSONColTable.push({ "width": "30px", "sClass": "dtbodyCenter", "aTargets": 6 });
                     aryJSONColTable.push({ "width": "30px", "aTargets": 7 });
                     aryJSONColTable.push({ "width": "30px", "sClass": "dtbodyCenter", "aTargets": 8 });

                     //aryJSONColTable.push({ "width": "30px", "sClass": "dtbodyCenter", "aTargets": 10 });

                     $('.gvCategoryHistory').DataTable({
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
                         buttons: [{
                             extend: 'copy',
                             exportOptions: {
                                 columns: ':visible',
                                 search: 'applied',
                                 order: 'applied'
                             },
                             footer: true
                         },
                         {
                             extend: 'csv', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),

                             customize: function (csv) {
                                 var data = $("#lnkTitle").text() + '\n';
                                 //data += 'Option,' + $('.ddlOption option:selected').text() + '\n';
                                 ////data += 'Discount Type,' + $('.ddlDiscountType option:selected').text() + '\n';
                                 //data += 'With History,' + ($('.chkIsHistory').find('input').is(':checked') ? "True" : "False") + '\n';
                                 data += 'UserId,' + $('.hdnUserName').val() + '\n';
                                 data += 'Created on,' + jsDate.toString() + '\n';
                                 return data + csv;
                             },
                             exportOptions: {
                                 columns: ':visible',
                                 search: 'applied',
                                 order: 'applied',
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
                             exportOptions: {
                                 columns: ':visible',
                                 search: 'applied',
                                 order: 'applied'
                             },
                             customize: function (xlsx) {

                                 sheet = ExportXLS(xlsx, 4);

                                 var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text() }]);
                                 //var r1 = Addrow(2, [{ key: 'A', value: 'Option' }, { key: 'B', value: $('.ddlOption option:selected').text() }]);
                                 ////  var r2 = Addrow(3, [{ key: 'A', value: 'Discount Type' }, { key: 'B', value: $('.ddlDiscountType option:selected').text() }]);
                                 //var r3 = Addrow(3, [{ key: 'A', value: 'With History' }, { key: 'B', value: ($('.chkIsHistory').find('input').is(':checked') ? "True" : "False") }]);
                                 var r4 = Addrow(2, [{ key: 'A', value: 'UserId' }, { key: 'B', value: $('.hdnUserName').val() }]);
                                 var r5 = Addrow(3, [{ key: 'A', value: 'Created on' }, { key: 'B', value: jsDate.toString() }]);
                                 sheet.childNodes[0].childNodes[1].innerHTML = r0 + r4 + r5 + sheet.childNodes[0].childNodes[1].innerHTML;
                             }
                         },
                         {
                             extend: 'pdfHtml5',
                             orientation: 'portrait', //portrait / landscape
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
                                                     { text: $("#lnkTitle").text() + '\n' },
                                                   //  { text: 'Option : ' + $('.ddlOption option:selected').text() + "\n" },
                                                   { text: 'With History : ' + ($('.chkIsHistory').find('input').is(':checked') ? "True" : "False") + "\n" },

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
                                 for (i = 1; i < rowCount; i++) { // rows alignment setting by default left
                                     doc.content[0].table.body[i][0].alignment = 'center';
                                     doc.content[0].table.body[i][1].alignment = 'left';
                                     doc.content[0].table.body[i][2].alignment = 'left';
                                     doc.content[0].table.body[i][3].alignment = 'left';
                                     doc.content[0].table.body[i][4].alignment = 'left';
                                     doc.content[0].table.body[i][5].alignment = 'left';
                                     doc.content[0].table.body[i][6].alignment = 'center';
                                     doc.content[0].table.body[i][7].alignment = 'left';
                                     doc.content[0].table.body[i][8].alignment = 'center';

                                     //  doc.content[0].table.body[i][10].alignment = 'left';
                                 };
                                 doc.content[0].table.body[0][0].alignment = 'center';
                                 doc.content[0].table.body[0][1].alignment = 'left';
                                 doc.content[0].table.body[0][2].alignment = 'left';
                                 doc.content[0].table.body[0][3].alignment = 'left';
                                 doc.content[0].table.body[0][4].alignment = 'left';
                                 doc.content[0].table.body[0][5].alignment = 'left';
                                 doc.content[0].table.body[0][6].alignment = 'center';
                                 doc.content[0].table.body[0][7].alignment = 'left';
                                 doc.content[0].table.body[0][8].alignment = 'center';
                                 // doc.content[0].table.body[0][9].alignment = 'left';
                                 //   doc.content[0].table.body[0][10].alignment = 'left';

                             }
                         }]
                     });
                 }
             }
         }
         function EndRequestHandler2(sender, args) {
             Relaod();
         }
         function Cancel() {
             window.location = "../Master/CategoryMaster.aspx";
         }
         function ClearControls() {
            $('.divCategoryEntry').attr('style', 'display:none;');
             $('.divCategoryReport').attr('style', 'display:none;');


             $('.divMissData').attr('style', 'display:none;');
             $('.btnSubmit').attr('style', 'display:none;');
             $('.btnSearch').attr('style', 'display:none;');
             $('#btnCancel').attr('style', 'display:none;');

             $('.divViewDetail').attr('style', 'display:none;');
             $('#tblDiscountExc tbody').empty();

             if ($.fn.DataTable.isDataTable('.gvCategoryHistory')) {
                 $('.gvCategoryHistory').DataTable().destroy();
             }

             $('.gvCategoryHistory tbody').empty();
             if ($('.chkIsReport').find('input').is(':checked')) {

                 $('.btnSearch').removeAttr('style');
                 $('#btnCancel').removeAttr('style');
                 $('.divViewDetail').removeAttr('style');
                 $('#btnAddNew').attr('style', 'display:none;');
                 $('.divsearch').attr('style', 'display:none;');

             }
             else {
                 $('.divCategoryEntry').removeAttr('style');
                 $('#btnAddNew').removeAttr('style');
                 $('.btnSubmit').removeAttr('style');
                 $('.divsearch').removeAttr('style');
                 //  $('.chkIsHistory').find('input').not(':checked');
                 $('.chkIsHistory').find('input').prop('checked', false);
                 //$('#myCheckbox').prop('checked', false);
                 $('#CountRowClaim').val(0);
             }

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
    </script>
    <style>
        .btnEditDelete {
            padding: 1px 3px !important;
        }

        .modal-dialog {
            width: 416px !important;
        }

        .dtbodyCenter {
            text-align: center;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <asp:HiddenField runat="server" ID="hdnIPAdd" ClientIDMode="Static" Value="0" />
    <input type="hidden" class="hdnUserName" id="hdnUserName" runat="server" />
    <div class="panel">
        <div class="panel-body ">
            <div class="row _masterForm">
                <div class="button-wrapper">
                     <div class="col-lg-2">
                         </div>
                    <div class="col-lg-2">
                        <div class="input-group form-group"  style="text-align: right;">
                            <input type="button" id="btnAddNew" tabindex="1" class="btn btn-default" onclick="myModal();" value="Add" />
                        </div>
                    </div>
                    <div class="col-lg-2">
                        <div class="input-group form-group">
                            <label class="input-group-addon">View Report</label>
                            <asp:CheckBox runat="server" CssClass="chkIsReport form-control" TabIndex="3" onchange="ClearControls();" />
                        </div>
                    </div>
                    <div class="divViewDetail">
                        <div class="col-lg-2">
                            <div class="input-group form-group">
                                <label class="input-group-addon">With History</label>
                                <asp:CheckBox runat="server" ID="chkIsHistory" TabIndex="4" CssClass="chkIsHistory form-control" />
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-2">
                        <div class="input-group form-group">
                            <input type="button" id="btnSearch" name="btnSearch" value="Process" tabindex="6" class="btnSearch btn btn-default" onclick="GetReport();" />
                            &nbsp
                        <input type="button" id="btnCancel" name="btnCancel" value="Cancel" tabindex="7" onclick="Cancel()" class="btn btn-default" />
                        </div>
                    </div>
                    <div class="col-lg-2 divsearch" style="text-align: right;">
                        Search<asp:TextBox runat="server" ID="txtACT2Search" CssClass="txtACT2Search" Style="float: right; background-image: url('../Images/Search.png'); background-position: right; margin-left: 0px; background-repeat: no-repeat" />
                    </div>
                </div>
            </div>
            <div id="divCategoryEntry" class="divCategoryEntry" runat="server" style="max-height: 80vh; position: absolute;">
                <div class="col-lg-12">
                    <asp:GridView runat="server" ID="gvCategory" CssClass="table gvCategory" ShowHeader="true" AutoGenerateColumns="false"
                        OnRowCommand="gvCategory_RowCommand" OnPreRender="gvCategory_PreRender" HeaderStyle-CssClass="table-header-gradient"
                        FooterStyle-CssClass="table-header-gradient" EmptyDataText="No Data Found." Font-Size="11px">
                        <Columns>
                            <asp:TemplateField HeaderText="Sr." HeaderStyle-Width="3px" HeaderStyle-CssClass="lblRight" ItemStyle-HorizontalAlign="Center">
                                <ItemTemplate>
                                    <%#Container.DataItemIndex+1 %>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Edit" ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="15px">
                                <ItemTemplate>
                                    <asp:Button Font-Size="11px" ID="btnEdit" runat="server" Text="Edit" CssClass="btn btn-default btnEditDelete" CommandName="EditMode" CommandArgument='<%#Eval("CategoryId") %>'></asp:Button>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Delete" ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="20px">
                                <ItemTemplate>
                                    <asp:LinkButton Font-Size="11px" ID="btnDelete" runat="server" CssClass="btn btn-default btnEditDelete" OnClientClick="return confirm('Are you sure you want to delete this category?');" CommandName="DeleteMode" CommandArgument='<%#Eval("CategoryId") %>'>Delete </asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField HeaderText="Category" DataField="CategoryCode" HeaderStyle-Width="30px" ItemStyle-HorizontalAlign="Left"></asp:BoundField>
                            <asp:BoundField HeaderText="Description" DataField="Description" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="130px"></asp:BoundField>
                            <asp:BoundField HeaderText="Active" DataField="Active" HeaderStyle-Width="20px" />
                            <asp:BoundField HeaderText="Created By" DataField="CreatedBy" HeaderStyle-Width="90px" />
                            <asp:BoundField HeaderText="Created Date" DataField="CreatedDate" DataFormatString="{0:dd-MMM-yy HH:mm}" HeaderStyle-Width="40px" ItemStyle-HorizontalAlign="Center">
                                <HeaderStyle CssClass="lblCenter" />
                            </asp:BoundField>
                            <asp:BoundField HeaderText="Updated By" DataField="UpdatedBy" HeaderStyle-Width="55px" />
                            <asp:BoundField HeaderText="Updated Date" DataField="UpdatedDate" DataFormatString="{0:dd-MMM-yy HH:mm}" HeaderStyle-Width="40px" ItemStyle-HorizontalAlign="Center">
                                <HeaderStyle CssClass="lblCenter" />
                            </asp:BoundField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
            <div id="divCategoryReport" class="divCategoryReport" style="max-height: 30vh; overflow-y: auto;">
                <table id="gvCategoryHistory" class="gvCategoryHistory table table-bordered nowrap" style="width: 100%; font-size: 10px;">
                    <thead>
                        <tr class="table-header-gradient">
                            <th style="text-align: center; width: 2%;">Sr</th>
                            <th style="width: 10%; padding-left: 5px !important;">Category</th>
                            <th style="width: 30%; padding-left: 5px !important;">Description</th>
                            <%-- <th style="width: 3%;">From-Date</th>
                            <th style="width: 3%;">To-Date</th>--%>
                            <th style="width: 3%; padding-left: 5px !important;">Active</th>
                            <th style="width: 2%; padding-left: 5px !important;">Deleted</th>
                            <th style="width: 10%; padding-left: 5px !important;">Entry By</th>
                            <th style="width: 8%;">Entry Date/Time</th>
                            <th style="width: 10%; padding-left: 5px !important;">Update By</th>
                            <th style="width: 8%;">Update Date/Time</th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    <!-- Modal -->
    <!-- Bootstrap Modal Dialog -->
    <div class="col-lg-12">
        <div class="modal fade" id="myCopyModal" role="dialog" aria-labelledby="myCopyModalLabel" aria-hidden="true" tabindex='-1'>
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" onclick="CloseModal()" aria-hidden="true">&times;</button>
                        <h4 class="modal-title">
                            <asp:Label ID="lblModalTitle" runat="server" Text="Category"></asp:Label></h4>
                        <asp:HiddenField ID="hdnCategoryId" runat="server"></asp:HiddenField>
                    </div>
                    <div class="">
                        <div class="col-lg-12">
                            <div class="input-group form-group">
                                <asp:Label ID="lblCategoryCode" runat="server" Text="Category" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtCategoryCode" TabIndex="1" runat="server" CssClass="txtCategory form-control" ClientIDMode="Static"></asp:TextBox>
                            </div>
                        </div>

                        <div class="col-lg-12">
                            <div class="input-group form-group">
                                <asp:Label ID="lblDiscription" runat="server" Text="Description" CssClass="input-group-addon"></asp:Label>
                                <asp:TextBox ID="txtDescription" runat="server" CssClass="txtDescription form-control" ClientIDMode="Static"></asp:TextBox>
                            </div>
                        </div>

                        <div class="col-lg-12">
                            <div class="input-group form-group">
                                <asp:Label ID="lblStatus" runat="server" Text="Active" CssClass="input-group-addon"></asp:Label>
                                <asp:CheckBox ID="chkActive" runat="server" CssClass="form-control" />
                            </div>
                        </div>
                        <div class="col-lg-12">
                            <asp:Button ID="saveData" CommandName="saveData" runat="server" Text="Submit" CssClass="btn btn-primary" OnClick="saveData_Click" />
                            <asp:Button ID="btnCancel" runat="server" OnClientClick="hideModal();" Text="Cancel" CssClass="btn btn-default" />
                        </div>
                    </div>
                    <div class="modal-footer">
                    </div>
                </div>
            </div>
        </div>
    </div>
    <!-- /.modal -->
</asp:Content>

