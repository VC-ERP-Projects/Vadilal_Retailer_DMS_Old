<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="AccountSAPStatusUpdate.aspx.cs" Inherits="Sales_AccountSAPStatusUpdate" %>

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
    <script type="text/javascript" src="../Scripts/fixHeaderFooter.js"></script>
    <script type="text/javascript">

        var CustType = <% = CustType%>;
        var ParentID = <% = ParentID%>;
        var Version = 'PRD';
        //  var LogoURL = '../Images/LOGO.png';

        var IpAddress;
        $(function () {
            $('.btnReport').attr('style', 'display:none;');
            ReLoadFn();

            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
            //$('.gvOrder').tableHeadFixer('65vh');
            //$('.divCustEntry').tableHeadFixer('65vh');
            $(".gvOrder").tableHeadFixer('55vh');
        });

        function EndRequestHandler2(sender, args) {
            ReLoadFn();
        }



        function ReloadRadio() {
            if ($('.chkCheck').length == $('.chkCheck:checked').length)
                $('.chkhead').prop('checked', true);
            else
                $('.chkhead').prop('checked', false);
        }
        //$(document).ready(function () {
        //    $('.gvOrder').DataTable();       //capital "D"

        //});
        function ReLoadFn() {

            var table = $('.gvOrder').DataTable();
            var aryJSONColTable = [];

            aryJSONColTable.push({ "bSortable": "false", "width": "20px", "sClass": "dtbodyCenter", "aTargets": 0 });
            aryJSONColTable.push({ "bSortable": "false", "width": "20px", "sClass": "dtbodyCenter", "aTargets": 1 });
            aryJSONColTable.push({ "bSortable": "false", "width": "25px", "aTargets": 2 });
            aryJSONColTable.push({ "bSortable": "false", "width": "25px", "aTargets": 3 });
            aryJSONColTable.push({ "bSortable": "false", "width": "75px", "aTargets": 4 });
            aryJSONColTable.push({ "bSortable": "false", "width": "35px", "aTargets": 5 });
            aryJSONColTable.push({ "bSortable": "false", "width": "70px", "aTargets": 6 });//"sClass": "dtbodyLeft",
            aryJSONColTable.push({ "bSortable": "false", "width": "30px", "sClass": "dtbodyRight", "aTargets": 7 });
            aryJSONColTable.push({ "bSortable": "false", "width": "35px", "sClass": "dtbodyCenter", "aTargets": 8 });
            aryJSONColTable.push({ "bSortable": "false", "width": "35px", "sClass": "dtbodyCenter", "aTargets": 9 });
            $('.gvOrder').DataTable({
                bFilter: false,
                scrollCollapse: false,
                "sExtends": "collection",
                scrollX: true,
                scrollY: '55vh',
                responsive: true,
                "bPaginate": false,
                ordering: false,
                "bInfo": true,
                "autoWidth": false,
                destroy: true,
                "aoColumnDefs": aryJSONColTable,
                "ordering": false,
                "bSort": false,
            });
            $('.dataTables_scrollFoot').css('overflow', 'auto');
            $($.fn.dataTable.tables(true)).DataTable().columns.adjust();
            $(".txtgvItemSearch").keyup(function () {
                var word = this.value;
                $(".gvOrder > tbody tr").not(':first').each(function () {
                    if ($(this).find("td").text().toUpperCase().indexOf(word.toUpperCase()) >= 0)
                        $(this).show();
                    else
                        $(this).hide();

                });
            });


            if ($('.gvEmpReasonHistory tbody tr').length > 0) {

                var now = new Date();
                Date.prototype.today = function () {
                    return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
                }

                var jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: false });

                var aryJSONColTable = [];

                aryJSONColTable.push({ "width": "10px", "sClass": "dtbodyCenter", "aTargets": 0 });
                aryJSONColTable.push({ "width": "90px", "sClass": "dtbodyLeft", "aTargets": 1 });
                aryJSONColTable.push({ "width": "90px", "sClass": "dtbodyLeft", "aTargets": 2 });
                aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyLeft", "aTargets": 3 });
                aryJSONColTable.push({ "width": "70px", "sClass": "dtbodyLeft", "aTargets": 4 });
                aryJSONColTable.push({ "width": "50px", "sClass": "dtbodyLeft", "aTargets": 5 });
                aryJSONColTable.push({ "width": "10px", "sClass": "dtbodyRight", "aTargets": 6 });
                aryJSONColTable.push({ "width": "10px", "sClass": "dtbodyCenter", "aTargets": 7 });
                aryJSONColTable.push({ "width": "40px", "sClass": "dtbodyLeft", "aTargets": 8 });
                aryJSONColTable.push({ "width": "20px", "sClass": "dtbodyCenter", "aTargets": 9 });
                setTimeout(function () {
                    $('.gvEmpReasonHistory').DataTable({
                        bFilter: true,
                        scrollCollapse: true,
                        "stripeClasses": ['odd-row', 'even-row'],
                        destroy: true,
                        scrollY: '60vh',
                        scrollX: true,
                        responsive: true,
                        dom: 'Bfrtip',
                        "bPaginate": false,
                        "bSort": false,
                        "aoColumnDefs": aryJSONColTable,
                        "order": [[0, "asc"]],
                        buttons: [{ extend: 'copy', footer: true },
                        //{
                        //    extend: 'csv', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                        //    customize: function (csv) {
                        //        var data = $("#lnkTitle").text() + '\n';
                        //       // data += 'With History,' + ($('.chkIsHistory').find('input').is(':checked') ? "True" : "False") + '\n';
                        //        data += 'UserId,' + $('.hdnUserName').val() + '\n';
                        //        data += 'Created on,' + jsDate.toString() + '\n';
                        //        return data + csv;
                        //    },
                        //    exportOptions: {
                        //        format: {
                        //            body: function (data, row, column, node) {
                        //                //check if type is input using jquery
                        //                return (data == "&nbsp;" || data == "") ? " " : data;
                        //                var D = data;
                        //            },
                        //            footer: function (data, row, column, node) {
                        //                //check if type is input using jquery
                        //                return (data == "&nbsp;" || data == "") ? " " : data;
                        //                var D = data;
                        //            }
                        //        }
                        //    }
                        //},
                        {
                            extend: 'excel', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString() + '_' + new Date().toLocaleTimeString('en-US'),
                            customize: function (xlsx) {

                                sheet = ExportXLS(xlsx, 4);

                                var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text() }]);
                                var r3 = Addrow(2, [{ key: 'A', value: 'Last Proceed From' }, { key: 'B', value: $('.fromdate').val() }]);
                                var r2 = Addrow(2, [{ key: 'A', value: 'Last Proceed To' }, { key: 'B', value: $('.todate').val() }]);
                                var r1 = Addrow(2, [{ key: 'A', value: 'Claim Type' }, { key: 'B', value: ($('.ddlMode option:selected').text() == '---Select---' ? 'ALL' : $('.ddlMode option:selected').text()) }]);
                                var r4 = Addrow(2, [{ key: 'A', value: 'UserId' }, { key: 'B', value: $('.hdnUserName').val() }]);
                                var r5 = Addrow(3, [{ key: 'A', value: 'Created on' }, { key: 'B', value: jsDate.toString() }]);
                                sheet.childNodes[0].childNodes[1].innerHTML = r0 + r3 + r2 + r1 + r4 + r5 + sheet.childNodes[0].childNodes[1].innerHTML;
                            }
                        },
                        {
                            extend: 'pdfHtml5',
                            orientation: 'landscape', //portrait
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
                                                    { text: 'Last Proceed From : ' + $('.fromdate').val() + "\n" },
                                                    { text: 'Last Proceed To : ' + $('.todate').val() + "\n" },
                                                    { text: 'Claim Type : ' + ($('.ddlMode option:selected').text() == '---Select---' ? 'ALL' : $('.ddlMode option:selected').text()) + "\n" },
                                                ],
                                                fontSize: 10,
                                                height: 350,
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
                                                text: ['Page ', { text: page.toString() }, ' of ', { text: pages.toString() }]
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
                                    doc.content[0].table.body[i][6].alignment = 'right';
                                    doc.content[0].table.body[i][7].alignment = 'center';
                                    doc.content[0].table.body[i][9].alignment = 'center';
                                };
                                doc.content[0].table.body[0][0].alignment = 'center';
                                doc.content[0].table.body[0][1].alignment = 'left';
                                doc.content[0].table.body[0][2].alignment = 'left';
                                doc.content[0].table.body[0][3].alignment = 'left';
                                doc.content[0].table.body[0][4].alignment = 'left';
                                doc.content[0].table.body[0][5].alignment = 'left';
                                doc.content[0].table.body[0][6].alignment = 'right';
                                doc.content[0].table.body[0][7].alignment = 'center';
                                doc.content[0].table.body[0][8].alignment = 'left';
                                doc.content[0].table.body[0][9].alignment = 'center';
                            }
                        }]
                    });
                }, 500)
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

        function ClickHead(chk) {
            if ($(chk).is(':checked')) {
                $('.chkCheck').prop('checked', true);
            }
            else {
                $('.chkCheck').prop('checked', false);
            }
        }

        function _btnCheck() {
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            IsValid = $('._masterForm').data('bootstrapValidator').isValid();
        }
        function OpenItemImage(ClaimId, ParentId, IsDownload) {

            if (IsDownload == 0) {

                $.colorbox({
                    width: '40%',
                    height: '40%',
                    iframe: true,
                    href: '../Sales/ClaimImage.aspx?ClaimId=' + ClaimId + '&ParentId=' + ParentId + '&IsParentClaim=1&IsDownload=0'
                });
            }
            else {
                console.log('5454565');
                window.location.assign('../Sales/ClaimImage.aspx?ClaimId=' + ClaimId + '&ParentId=' + ParentId + '&IsParentClaim=1&IsDownload=' + IsDownload)
                //$.colorbox({
                //    width: '40%',
                //    height: '40%',
                //    iframe: true,
                //    href: '../Sales/ClaimImage.aspx?ClaimId=' + ClaimId + '&ParentId=' + ParentId + '&IsParentClaim=1&IsDownload=' + IsDownload
                //});

            }
        }
        function ClearControls() {

            $('.divEmpReason').attr('style', 'display:none;');
            $('.divEmpReasonReport').attr('style', 'display:none;');

            $('.btnGenerat').attr('style', 'display:none;');
            $('.btnSearch').attr('style', 'display:none;');
            $('.btnReport').attr('style', 'display:none;');
            $('.divViewDetail').attr('style', 'display:none;');
            $('#gvOrder tbody').empty();

            //if ($.fn.DataTable.isDataTable('.gvEmpReasonHistory')) {
            //    $('.gvEmpReasonHistory').DataTable().destroy();
            //}
            //if ($.fn.DataTable.isDataTable('.gvOrder')) {
            //    $('.gvOrder').DataTable().destroy();
            //}
            $('.gvEmpReasonHistory tbody').empty();
            $('.gvOrder tbody').empty();
            if ($('.chkIsReport').find('input').is(':checked')) {
                console.log(34);
                $('.divEmpReasonReport').removeAttr('style');
                $('.btnReport').removeAttr('style');
                $('.btnGenerat').attr('style', 'display:none;');
                $('.btnSearch').attr('style', 'display:none;');
                $('.divViewDetail').removeAttr('style');
            }
            else {
                console.log(3445);
                $('.divEmpReason').removeAttr('style');
                $('.btnGenerat').removeAttr('style');
                $('.btnSearch').removeAttr('style');
                $('.btnReport').attr('style', 'display:none;');
                $('#gvOrder').DataTable().clear().destroy();
                $('.divEmpReasonReport').attr('style', 'display:none;');
            }
        }
        function getRept() {
            $('.divEmpReasonReport').removeAttr('style');
            $('.btnReport').removeAttr('style');
            $('.btnGenerat').attr('style', 'display:none;');
            $('.btnSearch').attr('style', 'display:none;');
            $('.divViewDetail').removeAttr('style');
            $('.divEmpReason').attr('style', 'display:none;');

        }
        function GetSearch() {
            $('.divEmpReason').removeAttr('style');
            $('.btnGenerat').removeAttr('style');
            $('.btnSearch').removeAttr('style');
            $('.btnReport').attr('style', 'display:none;');
            $('.divEmpReasonReport').attr('style', 'display:none;');
        }
    </script>
    <style>
        #page-content-wrapper {
            overflow: hidden;
        }

        dataTables_scroll .dataTables_scrollBody {
            overflow-y: hidden !important;
            overflow-x: hidden !important;
            max-height: none !important;
        }


        .element::-webkit-scrollbar {
            width: 0 !important;
        }

        #body_gvEmpReasonHistory_wrapper.dataTables_scrollHead {
            margin-left: 188px !important;
        }

        #body_gvEmpReasonHistory_wrapper .dataTables_scroll {
            overflow: hidden;
            /* margin-left:-139px !important;*/
        }

        .dataTables_scroll {
            overflow: hidden;
        }

        #body_gvEmpReasonHistory_wrapper .dataTables_scrollBody {
            margin-left: -119px !important;
        }

        #body_gvOrder_wrapper .dataTables_scrollBody {
            overflow-x: hidden !important;
            overflow-y: auto !important;
        }

        div.dataTables_wrapper {
            margin: 0 auto;
        }

        .table > thead > tr > th, .table > tbody > tr > th, .table > tfoot > tr > th, .table > thead > tr > td, .table > tbody > tr > td, .table > tfoot > tr > td {
            /*padding-left: 4px !important;*/
            padding: 0px !important;
            vertical-align: middle !important;
            /*white-space: nowrap;*/
            /*overflow-x: scroll;*/
        }
        /*   @media (min-width: 768px) {
            .container {
                max-width: 100%;
            }
        }

        @media (min-width: 1200px) {
            .container {
                width: 900px;
            }
        }

        @media (min-width: 992px) {
            .container {
                max-width: 100%;
            }
        }*/

        @media (min-width: 1200px) {
            /*.dataTables_scrollHead {
                width: 100% !important;
            }
            .dataTables_scrollFoot {
                width: 100% !important;
            }

            .dataTables_scrollFootInner {
                width: 100% !important;
            }*/
            #body_gvOrder_wrapper .dataTables_scrollHead {
                width: 1310px !important;
            }

            /*   #body_gvOrder_wrapper .dataTables_scrollBody {
                width: 930px !important;
            }*/

            #body_gvOrder_wrapper .dataTables_scrollFoot {
                width: 930px !important;
            }

            #body_gvOrder_wrapper .dataTables_scrollFootInner {
                width: 930px !important;
            }

            .dtbodyRight {
                text-align: right;
            }
        }



        .tdleftalign {
            margin-left: 3px !important;
            margin-right: 7px !important;
        }

        .tdrightalign {
            margin-right: 4px !important;
        }

        .CustName {
            /*overflow: auto;*/
            white-space: nowrap;
            overflow-x: scroll;
            margin-left: 3px !important;
        }

            .CustName::-webkit-scrollbar {
                display: none;
            }


        /* Hide scrollbar for IE, Edge and Firefox */
        .CustName {
            -ms-overflow-style: none; /* IE and Edge */
            scrollbar-width: none; /* Firefox */
        }

        .dataTables_wrapper.no-footer .dataTables_scrollBody {
            border-bottom: none !important;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body _masterForm">
            <div class="row">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromDate" runat="server" Text="Last Proceed From" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromDate" runat="server" TabIndex="1" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="fromdate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate" runat="server" Text="Last Proceed To" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtToDate" runat="server" TabIndex="2" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="todate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Claim Type" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList runat="server" ID="ddlMode" CssClass="ddlMode form-control" TabIndex="2">
                        </asp:DropDownList>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-8">
                    <asp:Button ID="btnSearch" runat="server" Text="Search" TabIndex="10" CssClass="btn btn-default" OnClientClick="return _btnCheck();" OnClick="btnSearch_Click" />
                    <asp:Button ID="btnGenerat" runat="server" Text="Submit" TabIndex="11" CssClass="btn btn-info" OnClick="btnGenerat_Click" />
                </div>
                <div class="col-lg-4">
                    <asp:TextBox runat="server" placeholder="Search here" ID="txtgvItemSearch" TabIndex="14" CssClass="txtgvItemSearch" Style="display: inline-block; width: 100%; background-image: url('../Images/Search.png'); background-position: right; margin-left: 0px; background-repeat: no-repeat" />
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12">
                    
                        <asp:GridView runat="server" ID="gvOrder" CssClass="gvOrder nowrap table"  AutoGenerateColumns="false" Style="border-collapse: collapse;" Font-Size="11px" HeaderStyle-CssClass="table-header-gradient" OnPreRender="gvOrder_Prerender">
                            <Columns>
                                <asp:TemplateField HeaderText="Sr." HeaderStyle-CssClass="dtbodyCenter">
                                    <ItemTemplate>
                                        <asp:Label ID="lblNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Label>
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Center" />
                                    <HeaderStyle HorizontalAlign="Right" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Check" HeaderStyle-CssClass="dtbodyCenter" HeaderStyle-Width="60px">
                                    <HeaderTemplate>
                                        <input type="checkbox" name="chkhead" class="chkhead" id="chkhead" runat="server" onchange="ClickHead(this);" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <input type="checkbox" name="chkCheck" class="chkCheck" id="chkcheck" runat="server" onchange="ReloadRadio();" />
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Center" />
                                    <HeaderStyle HorizontalAlign="Center" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Year / Month" HeaderStyle-Width="84px">
                                    <ItemTemplate>
                                        <asp:Label ID="lblober" Text='<%# Eval("YearMonth") %>' runat="server" CssClass="tdleftalign"></asp:Label>
                                        <asp:Label ID="lblCustomerId" Text='<%# Eval("CustomerID") %>' runat="server" Visible="false" CssClass="tdleftalign"></asp:Label>
                                        <asp:Label ID="lblClaimReqId" Text='<%# Eval("ClaimRequestID") %>' runat="server" Visible="false" CssClass="tdleftalign"></asp:Label>
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Left" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Code" HeaderStyle-CssClass="tdleftalign" HeaderStyle-Width="57px">
                                    <ItemTemplate>
                                        <asp:Label ID="lblndate" Text='<%# Eval("CustomerCode") %>' runat="server" CssClass="tdleftalign"> </asp:Label>
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Left" />
                                    <HeaderStyle HorizontalAlign="Left" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Name" ItemStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" HeaderStyle-HorizontalAlign="Left">
                                    <ItemTemplate>
                                        <asp:Label ID="lblnber" Text='<%# Eval("CustomerName") %>' runat="server" CssClass="tdleftalign"></asp:Label>
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Left" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="City"  ItemStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" HeaderStyle-HorizontalAlign="Left">
                                    <ItemTemplate>
                                        <asp:Label ID="lblTotalInvoice" runat="server" Text='<%# Eval("CityName") %>' CssClass="tdleftalign"></asp:Label>
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Left" />
                                    <HeaderStyle HorizontalAlign="Left" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Claim Type" ItemStyle-HorizontalAlign="Left" ItemStyle-CssClass="CustName" HeaderStyle-HorizontalAlign="Left">
                                    <ItemTemplate>
                                        <asp:Label ID="lblVehicleNo" Text='<%# Eval("ReasonName") %>' runat="server" CssClass="tdleftalign"></asp:Label>
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Left" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Claim Amount" ItemStyle-CssClass="dtbodyRight">
                                    <ItemTemplate>
                                        <asp:Label ID="lblCust" Text='<%# Eval("ApprovedAmount") %>' runat="server" CssClass="tdleftalign"></asp:Label>
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Right" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Synced Date" HeaderStyle-CssClass="dtbodyCenter">
                                    <ItemTemplate>
                                        <asp:Label ID="lblQty" Text='<%# Eval("SyncDateTime") %>' runat="server" CssClass="tdrightalign"></asp:Label>
                                    </ItemTemplate>
                                    <ItemStyle HorizontalAlign="Center" />
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>

                
            </div>
        </div>
    </div>
</asp:Content>

