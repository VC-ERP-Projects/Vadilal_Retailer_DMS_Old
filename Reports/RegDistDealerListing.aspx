<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="RegDistDealerListing.aspx.cs" Inherits="Reports_RegDistDealerListing" %>

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
                var pre = "";
                var ind = "";
                var splited = $(this).attr('r').split(/([0-9]+)/);

                if (splited[0].length == 2) {
                    pre = splited[0];
                    ind = parseInt(attr.substring(2, attr.length));
                } else {
                    pre = splited[0];
                    ind = parseInt(attr.substring(1, attr.length));
                }
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

        $(function () {
            ReLoadFn();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            ReLoadFn();
        }

        function ReLoadFn() {
            var month = new Array();
            month[0] = "Jan";
            month[1] = "Feb";
            month[2] = "Mar";
            month[3] = "Apr";
            month[4] = "May";
            month[5] = "Jun";
            month[6] = "Jul";
            month[7] = "Aug";
            month[8] = "Sep";
            month[9] = "Oct";
            month[10] = "Nov";
            month[11] = "Dec";

            var now = new Date();
            Date.prototype.today = function () {
                return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + month[this.getMonth()] + "/" + (this.getFullYear()).toString().substring(2, 4);
            }
            var jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: true });
            if ($('.gvRegDistDealer thead tr').length > 0) {

                var aryJSONColTable = [];

                aryJSONColTable.push({ "width": "20px", "aTargets": 0 });
                aryJSONColTable.push({ "width": "200px", "aTargets": 1 });
                aryJSONColTable.push({ "width": "200px", "aTargets": 2 });
                aryJSONColTable.push({ "width": "100px", "aTargets": 3 });
                aryJSONColTable.push({ "width": "100px", "aTargets": 4 });
                aryJSONColTable.push({ "width": "60px", "aTargets": 5 });
                aryJSONColTable.push({ "width": "100px", "aTargets": 6 });
                aryJSONColTable.push({ "width": "200px", "aTargets": 7 });
                aryJSONColTable.push({ "width": "200px", "aTargets": 8 });
                aryJSONColTable.push({ "width": "200px", "aTargets": 9 });
                aryJSONColTable.push({ "width": "200px", "aTargets": 10 });
                aryJSONColTable.push({ "width": "100px", "aTargets": 11 });
                aryJSONColTable.push({ "width": "60px", "aTargets": 12 });
                aryJSONColTable.push({ "width": "100px", "aTargets": 13 });
                aryJSONColTable.push({ "width": "100px", "aTargets": 14 });
                aryJSONColTable.push({ "width": "80px", "aTargets": 15 });
                aryJSONColTable.push({ "width": "80px", "aTargets": 16 });
                aryJSONColTable.push({ "width": "80px", "aTargets": 17 });
                aryJSONColTable.push({ "width": "200px", "aTargets": 18 });
                aryJSONColTable.push({ "width": "80px", "aTargets": 19 });
                aryJSONColTable.push({ "width": "80px", "aTargets": 20 });
                aryJSONColTable.push({ "width": "50px", "aTargets": 21 });
                aryJSONColTable.push({ "width": "200px", "aTargets": 22 });
                aryJSONColTable.push({ "width": "200px", "aTargets": 23 });
                aryJSONColTable.push({ "width": "200px", "aTargets": 24 });
                aryJSONColTable.push({ "width": "200px", "aTargets": 25 });
                aryJSONColTable.push({ "width": "260px", "aTargets": 26 });
                aryJSONColTable.push({ "width": "90px", "aTargets": 27 });
                aryJSONColTable.push({ "width": "90px", "aTargets": 28 });
                aryJSONColTable.push({ "width": "60px", "aTargets": 29 });

                $('.gvRegDistDealer').DataTable({
                    bFilter: true,
                    scrollCollapse: true,
                    destroy: true,
                    "ordering": true,
                    "order": [[0, "asc"]],
                    scrollY: '50vh',
                    scrollX: true,
                    responsive: true,
                    "aoColumnDefs": aryJSONColTable,
                    dom: 'Bfrtip',
                    "stripeClasses": ['odd-row', 'even-row'],
                    "bPaginate": false,
                    buttons: [{ extend: 'copy', footer: true },
                               {
                                   extend: 'csv', footer: true, filename: $("#lnkTitle").text() + '_' + new Date().toLocaleDateString(),
                                   customize: function (csv) {
                                       var data = $("#lnkTitle").text() + '\n';
                                       data += 'Dist. Region,' + (($('.txtDistRegion').length > 0 && $('.txtDistRegion').val() != "") ? $('.txtDistRegion').val().split('-')[1] : "All Region") + '\n';
                                       data += 'Distributor,' + (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") + '\n';
                                       data += 'Dist. Status,' + $('.ddlSAPDistStatus option:Selected').text() + '\n';
                                       data += 'Dealer Region,' + (($('.txtDealRegion').length > 0 && $('.txtDealRegion').val() != "") ? $('.txtDealRegion').val().split('-')[1] : "All Region") + '\n';
                                       data += 'Dealer Status,' + $('.ddlSAPDealStatus option:Selected').text() + '\n';
                                       data += 'Employee,' + (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "All Employee") + '\n';
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

                                       sheet = ExportXLS(xlsx, 11);

                                       var r0 = Addrow(1, [{ key: 'A', value: $("#lnkTitle").text() }]);
                                       var r1 = Addrow(2, [{ key: 'A', value: 'Dist. Region' }, { key: 'B', value: (($('.txtDistRegion').length > 0 && $('.txtDistRegion').val() != "") ? $('.txtDistRegion').val().split('-')[1] : "All Region") }]);
                                       var r2 = Addrow(3, [{ key: 'A', value: 'Distributor' }, { key: 'B', value: (($('.txtDistCode').length > 0 && $('.txtDistCode').val() != "") ? $('.txtDistCode').val().split('-').slice(0, 2) : "") }]);
                                       var r3 = Addrow(4, [{ key: 'A', value: 'Dist. Status' }, { key: 'B', value: ($('.ddlSAPDistStatus option:Selected').text()) }]);
                                       var r4 = Addrow(5, [{ key: 'A', value: 'Dealer Region' }, { key: 'B', value: (($('.txtDealRegion').length > 0 && $('.txtDealRegion').val() != "") ? $('.txtDealRegion').val().split('-')[1] : "All Region") }]);
                                       var r5 = Addrow(6, [{ key: 'A', value: 'Dealer Status' }, { key: 'B', value: ($('.ddlSAPDealStatus option:Selected').text()) }]);
                                       var r6 = Addrow(7, [{ key: 'A', value: 'Employee' }, { key: 'B', value: (($('.txtCode').length > 0 && $('.txtCode').val() != "") ? $('.txtCode').val().split('-').slice(0, 2) : "All Employee") }]);
                                       var r7 = Addrow(8, [{ key: 'A', value: 'User Name' }, { key: 'B', value: $('.hdnUserName').val() }]);
                                       var r8 = Addrow(9, [{ key: 'A', value: 'Created on' }, { key: 'B', value: jsDate.toString() }]);
                                       sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r3 + r4 + r5 + r6 + r7 + r8 + sheet.childNodes[0].childNodes[1].innerHTML;
                                   }
                               }]
                });
            }
        }

        function _btnCheck() {

            var IsValid = true;

            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            IsValid = $('._masterForm').data('bootstrapValidator').isValid();
            return IsValid;
        }

        function autoCompleteState_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            sender.set_contextKey(EmpID);
        }

        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            var Region = $('.txtDistRegion').is(":visible") ? $('.txtDistRegion').val().split('-').pop() : "0";
            var Status = $('.ddlSAPDistStatus option:Selected').val();
            sender.set_contextKey(Region + "-" + Status + "-" + EmpID);
        }
        function autoCompleteDealerCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtCode').is(":visible") ? $('.txtCode').val().split('-').pop() : "0";
            var Region = $('.txtDistRegion').is(":visible") ? $('.txtDistRegion').val().split('-').pop() : "0";
            var Dist = $('.txtDistCode').is(":visible") ? $('.txtDistCode').val().split('-').pop() : "0";
            var Status = $('.ddlSAPDealStatus option:Selected').val();
            sender.set_contextKey(Region + "-" + Status + "-" + Dist + "-" + EmpID);
        }
    </script>
    <style type="text/css">
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

        div.dataTables_wrapper {
            margin: 0 auto;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4" id="divEmpCode" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" runat="server" CssClass="form-control txtCode" Style="background-color: rgb(250, 255, 189);" TabIndex="1"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4" id="divRegion" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblRegion" runat="server" Text='Dist. Region' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDistRegion" CssClass="txtDistRegion form-control" runat="server" Style="background-color: rgb(250, 255, 189);" TabIndex="2"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender1" runat="server"
                            ServiceMethod="GetDistributorRegionCurrHierarchy" ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1"
                            TargetControlID="txtDistRegion" UseContextKey="True" OnClientPopulating="autoCompleteState_OnClientPopulating">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                 <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblDMSDistStatus" runat="server" Text="Dist. DMS Status" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlDMSDistStatus" runat="server" TabIndex="3" CssClass="ddlDMSDistStatus form-control">
                            <asp:ListItem Text="All" Value="2" Selected="True" />
                            <asp:ListItem Text="Active" Value="1" />
                            <asp:ListItem Text="In-Active" Value="0" />
                        </asp:DropDownList>
                    </div>
                </div>
                 <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblSAPDistStatus" runat="server" Text="Dist. SAP Status" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlSAPDistStatus" runat="server" TabIndex="3" CssClass="ddlSAPDistStatus form-control">
                            <asp:ListItem Text="All" Value="2" Selected="True" />
                            <asp:ListItem Text="Active" Value="1" />
                            <asp:ListItem Text="In-Active" Value="0" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4 divDistributor" id="divDistributor" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDistCode" runat="server" TabIndex="4" Style="background-color: rgb(250, 255, 189);" CssClass="txtDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDistributorCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4" id="divDealerRegion" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblDealRegion" runat="server" Text='Dealer Region' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtDealRegion" CssClass="txtDealRegion form-control" runat="server" Style="background-color: rgb(250, 255, 189);" TabIndex="5"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender2" runat="server" OnClientPopulating="autoCompleteDealerCode_OnClientPopulating"
                            ServiceMethod="GetDealerRegionCurrHierarchy" ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1"
                            TargetControlID="txtDealRegion" UseContextKey="True">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblDMSDealerStatus" runat="server" Text="Dealer DMS Status" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlDMSDealerStatus" runat="server" TabIndex="6" CssClass="ddlDMSDealerStatus form-control">
                            <asp:ListItem Text="All" Value="2" Selected="True" />
                            <asp:ListItem Text="Active" Value="1" />
                            <asp:ListItem Text="In-Active" Value="0" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblSAPDealerStatus" runat="server" Text="Dealer SAP Status" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlSAPDealStatus" runat="server" TabIndex="6" CssClass="ddlSAPDealStatus form-control">
                            <asp:ListItem Text="All" Value="2" Selected="True" />
                            <asp:ListItem Text="Active" Value="1" />
                            <asp:ListItem Text="In-Active" Value="0" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <input type="hidden" class="hdnUserName" id="hdnUserName" runat="server" />
                        <asp:Button ID="btnGenerat" runat="server" Text="Generate" TabIndex="7" CssClass="btn btn-default" OnClientClick="return _btnCheck();" OnClick="btnGenerat_Click" />
                    </div>
                </div>
            </div>
            <br />
            <div class="row">
                <div class="col-lg-12">
                    <asp:GridView ID="gvRegDistDealer" runat="server" CssClass="gvRegDistDealer table" Style="font-size: 11px;" Width="100%"
                        OnPreRender="gvRegDistDealer_PreRender" ShowFooter="True" ShowHeader="true" HeaderStyle-CssClass=" table-header-gradient" FooterStyle-CssClass=" table-header-gradient"
                        EmptyDataText="No data found. ">
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

