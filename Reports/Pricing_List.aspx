<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="Pricing_List.aspx.cs" Inherits="Reports_Pricing_List" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../Scripts/datatable_new/jquery.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/datatable_new/buttons.dataTables.min.css" rel="stylesheet" />
    <link href="../Scripts/datatable_new/fixedColumns.bootstrap.min.css" rel="stylesheet" />

    <script src="../Scripts/datatable_new/jquery.dataTables.min.js"></script>
    <script src="../Scripts/datatable_new/dataTables.buttons.min.js"></script>
    <script src="../Scripts/datatable_new/buttons.html5.min.js"></script>
    <script src="../Scripts/datatable_new/pdfmake.min.js"></script>
    <script src="../Scripts/datatable_new/vfs_fonts.js"></script>
    <script src="../Scripts/datatable_new/jszip.min.js"></script>
      <script src="../Scripts/datatable_new/dataTables.fixedColumns.min.js"></script>

    <script type="text/javascript">
        
        var CustType = <% = CustType%>;
        var ParentID = <% = ParentID%>;

        $(function () {
            ReLoadFn();
            ChangeReportFor('1');
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            ReLoadFn();
            ChangeReportFor('1');
        }

       
        function _btnCheck() {

            var IsValid = true;

            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            IsValid = $('._masterForm').data('bootstrapValidator').isValid();
            return IsValid;
        }
        function acetxtCustName_OnClientPopulating(sender, args) {
            var ss = $('.txtSSDistCode').val().split('-')[2];             
            var key = $('.txtCustCode').val().split('-')[2];
            sender.set_contextKey("0-0-0" + "-"+ ss + "-" + key);
            // sender.get_completionList().style.width = 500;
        }
        
        function autoCompleteDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtEmpCode').is(":visible") ? $('.txtEmpCode').val().split('-').pop() : "0";
            var reg = $('.txtRegion').is(":visible") ? $('.txtRegion').val().split('-').pop() : "0";

            var ss = "";
            if (CustType == 4)
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : ParentID;
            else
                ss = $('.txtSSDistCode').is(":visible") ? $('.txtSSDistCode').val().split('-').pop() : "0";
            sender.set_contextKey(reg+ "-0-" + "0" + "-" + ss + "-" + EmpID);
        }

        
        function autoCompleteSSDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtEmpCode').is(":visible") ? $('.txtEmpCode').val().split('-').pop() : "0";
            var reg = $('.txtRegion').is(":visible") ? $('.txtRegion').val().split('-').pop() : "0";

            sender.set_contextKey(reg + "-0-" + "0" + "-" + EmpID);
        }

        function autoCompleteState_OnClientPopulating(sender, args) {
            var EmpID = $('.txtEmpCode').is(":visible") ? $('.txtEmpCode').val().split('-').pop() : "0";

            sender.set_contextKey(EmpID);
        }
        function ChangeReportFor(SelType) {
            if ($('.ddlCustType').val() == "4") {
                if (SelType == "2") {
                    $('.txtSSDistCode').val('');
                    $('.txtCustCode').val('');
                }
                $('.divSS').removeAttr('style');
                $('.divDistributor').attr('style', 'display:none;');
            }
            else {
                if (SelType == "2") {
                    $('.txtSSDistCode').val('');
                    $('.txtCustCode').val('');
                }
                $('.divSS').attr('style', 'display:none;');
                $('.divDistributor').removeAttr('style');
            }
        }
        function acetxtPriceList_OnClientPopulating(sender, args) {

            var Dealer =  $('.txtdealer').val();
            var SS = $('.txtSSDistCode').val();
            var Dist =$('.txtCustCode').val(); 
            var Division = $('.ddlDivision option:Selected').val();

            if (Dealer != "") {
                var key = $('.txtdealer').val().split('-')[2] + "#" + Division;
                if (key != undefined)
                    sender.set_contextKey(key);
            }
            else if(Dist != ""){
                var key = $('.txtCustCode').val().split('-')[2] + "#" + Division;
                if (key != undefined)
                    sender.set_contextKey(key);
            }
            else
            {
                var key = $('.txtSSDistCode').val().split('-')[2] + "#" + Division;
                if (key != undefined)
                    sender.set_contextKey(key);
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

        function ReLoadFn() {

            if ($('.gvprice thead tr').length > 0) {
                var table = $('.gvprice').DataTable();
                var colCount = table.columns()[0].length;

                var aryJSONColTable = [];
                aryJSONColTable.push({ "width": "25px","sClass": "dtbodyRight", "aTargets": 0 });
                aryJSONColTable.push({ "width": "75px", "aTargets": 1 });
                aryJSONColTable.push({ "width": "200px", "aTargets": 2 });
                aryJSONColTable.push({ "width": "120px","aTargets": 3 });
                aryJSONColTable.push({ "width": "120px","aTargets": 4 });
                aryJSONColTable.push({ "width": "40px","aTargets": 5 });
                aryJSONColTable.push({ "width": "120px", "sClass": "dtbodyRight","aTargets": 6 });
                aryJSONColTable.push({ "width": "50px","sClass": "dtbodyRight","aTargets": 7});
                
                for (var i = 8; i < colCount; i++) {

                    aryJSONColTable.push({
                        "aTargets": [i],
                        "sClass": "dtbodyRight",
                        "width": "120px"
                    });
                }
                var now = new Date();
                Date.prototype.today = function () {
                    return ((this.getDate() < 10) ? "0" : "") + this.getDate() + "/" + (((this.getMonth() + 1) < 10) ? "0" : "") + (this.getMonth() + 1) + "/" + this.getFullYear();
                }
                var jsDate = new Date().today() + ' ' + now.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: true });
              
                $('.gvprice').DataTable({
                    bFilter: true,
                    scrollCollapse: true,
                    "stripeClasses": ['odd-row', 'even-row'],
                    destroy: true,
                    scrollY: '50vh',
                    scrollX: true,
                    responsive: true,
                    "autoWidth": false,
                    "aaSorting": [],
                    fixedColumns: {
                        leftColumns: 4
                    },
                    dom: 'Bfrtip',
                    "bPaginate": false,
                    "aoColumnDefs": aryJSONColTable,
                    buttons: [{ extend: 'copy', footer: true },
                       {
                           extend: 'csv', 
                           footer: true,
                           filename: 'Material Pricing Listing For '+ $('.ddlDivision option:Selected').text() + new Date().toLocaleDateString(),
                           customize: function (csv) {
                               var data = 'Material Pricing Listing For '+ $('.ddlDivision option:Selected').text()+'\n';
                               data = 'Employee,' + (($('.txtEmpCode').length > 0 && $('.txtEmpCode').val() != "") ? $('.txtEmpCode').val().split("-")[0] + " - " + $('.txtEmpCode').val().split("-")[1] : "All") + '\n';
                               data += 'Region,' + (($('.txtRegion').length > 0 && $('.txtRegion').val() != "") ? $('.txtRegion').val().split('-')[1] : "All") + '\n';
                               data += 'Customer Type,' +  $('.ddlCustType option:Selected').text() + '\n';
                               data += 'Customer,' + (($('.txtCustCode').length > 0 && $('.txtCustCode').val() != "")  ? ($('.txtCustCode').val().split('-')[0]+'#'+$('.txtCustCode').val().split('-')[1]) : "") + '\n';
                               data += 'Division,' +  $('.ddlDivision option:Selected').text() + '\n';
                               data += 'Item Group,' +  (($('.ddlItemGroup').val() > 0 && $('.ddlItemGroup').val() != "") ? $('.ddlItemGroup option:Selected').text() : "All") + '\n';
                               data += 'Item Sub-Group,' +  (($('.ddlSubGroup').val() > 0 && $('.ddlSubGroup').val() != "") ? $('.ddlSubGroup option:Selected').text() : "All") + '\n';
                               data += 'Material Status,' +  $('.ddlMaterialStatus option:Selected').text() + '\n';
                               data += 'Created By,' + $('.txtEmpName').val() + '\n';
                               data += 'Created On,' + jsDate.toString() + '\n';
                               
                               return data + csv;
                           },
                           exportOptions: {
                               format: {
                                   body: function (data, row, column, node) {
                                       //check if type is input using jquery
                                       return (data == "&nbsp;" || data == "") ? " " : data;
                                   },
                                   footer: function (data, row, column, node) {
                                       //check if type is input using jquery
                                       return (data == "&nbsp;" || data == "") ? " " : data;
                                   }
                               }
                           }
                       },
                       {
                           extend: 'excel', footer: true, 
                           filename: 'Material Pricing Listing For '+ $('.ddlDivision option:Selected').text() + new Date().toLocaleDateString(),
                           customize: function (xlsx) {

                               sheet = ExportXLS(xlsx, 11);

                               var r0 = Addrow(1, [{ key: 'A', value: 'Material Pricing Listing For '+ $('.ddlDivision option:Selected').text()  }]);
                               var r1 = Addrow(2, [{ key: 'A', value: 'Employee' }, { key: 'B', value:  (($('.txtEmpCode').length > 0 && $('.txtEmpCode').val() != "")  ? ($('.txtEmpCode').val().split('-')[0]+'#'+$('.txtEmpCode').val().split('-')[1]) : "") }]);
                               var r2 = Addrow(3, [{ key: 'A', value: 'Region' }, { key: 'B', value: (($('.txtRegion').length > 0 && $('.txtRegion').val() != "") ? $('.txtRegion').val().split('-')[1] : "All") }]);
                               var r3 = Addrow(4,[{ key: 'A', value: 'Customer Type' }, { key: 'B', value:   $('.ddlCustType option:Selected').text() }]);
                               var r4 = Addrow(5, [{ key: 'A', value: 'Customer' }, { key: 'B', value: (($('.txtCustCode').length > 0 && $('.txtCustCode').val() != "")  ? ($('.txtCustCode').val().split('-')[0]+'#'+$('.txtCustCode').val().split('-')[1]) : "") }]);
                               var r5 = Addrow(6,[{ key: 'A', value: 'Division' }, { key: 'B', value:   $('.ddlDivision option:Selected').text() }]);
                               var r6 = Addrow(7, [{ key: 'A', value: 'Item Group' }, { key: 'B', value: (($('.ddlItemGroup').val() > 0 && $('.ddlItemGroup').val() != "") ? $('.ddlItemGroup option:Selected').text() : "All") }]);
                               var r7 = Addrow(8, [{ key: 'A', value: 'Item Sub-Group' }, { key: 'B', value: (($('.ddlSubGroup').val() > 0 && $('.ddlSubGroup').val() != "") ? $('.ddlSubGroup option:Selected').text() : "All") }]);
                               var r8 = Addrow(9,[{ key: 'A', value: 'Material Status' }, { key: 'B', value: $('.ddlMaterialStatus option:Selected').text() }]);
                               var r9 = Addrow(10, [{ key: 'A', value: 'Created By' }, { key: 'B', value:   $('.txtEmpName').val() }]);
                               var r10 = Addrow(11,[{ key: 'A', value: 'Created On'}, { key: 'B', value: jsDate.toString()}]);
                               sheet.childNodes[0].childNodes[1].innerHTML = r0 + r1 + r2 + r3 + r4 + r5 + r6 + r7 + r8 + r9 + r10 +  sheet.childNodes[0].childNodes[1].innerHTML;
                           }
                       }
                       
                    ],
                });
            }
        }
        
        function ClearOtherConfig() {
            if ($(".txtEmpCode").length > 0) {
                $(".txtRegion").val('');
                $(".txtCustCode").val('');
                $(".txtSSDistCode").val('');
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

        .dtbodyRight {
            text-align: right;
        }

        div.dataTables_wrapper {
            margin: 0 auto;
        }

        table.dataTable thead th, table.dataTable thead td {
            padding: 10px 18px 10px 3px;
        }

        table.dataTable tbody tr td {
            padding-left: 3px;
        }

        .dataTables_scrollHeadInner {
            width: auto !important;
        }

            .dataTables_scrollHeadInner table.dataTable {
                width: 100% !important;
            }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body _masterForm">
            <div class="row ">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCode" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtEmpCode" onchange="ClearOtherConfig()" runat="server" CssClass="form-control txtEmpCode" Style="background-color: rgb(250, 255, 189);" TabIndex="1"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtEmpCode">
                        </asp:AutoCompleteExtender>
                    </div>

                    <div class="input-group form-group divSS" id="divSS" runat="server">
                        <asp:Label ID="lblSSCustomer" runat="server" Text="Super Stockist" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtSSDistCode" runat="server" TabIndex="4" Style="background-color: rgb(250, 255, 189);" CssClass="txtSSDistCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="aceSStxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetSSCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteSSDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtSSDistCode">
                        </asp:AutoCompleteExtender>
                    </div>
                    <div class="input-group form-group divDistributor" id="divDistributor" runat="server">
                        <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCustCode" runat="server" TabIndex="4" Style="background-color: rgb(250, 255, 189);" CssClass="txtCustCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDistCurrHierarchy" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCustCode" OnClientPopulating="autoCompleteDistriCode_OnClientPopulating">
                        </asp:AutoCompleteExtender>
                    </div>

                    <div class="input-group form-group">
                        <asp:Label ID="lblSubGroup" runat="server" Text="Item Sub Group" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlSubGroup" runat="server" DataTextField="ItemSubGroupName" CssClass="ddlSubGroup form-control" TabIndex="7"
                            DataValueField="ItemSubGroupID">
                        </asp:DropDownList>
                    </div>
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Generate" CssClass="btn btn-default" OnClientClick="return _btnCheck();" OnClick="btnGenerat_Click" TabIndex="9" />
                        <asp:TextBox ID="txtEmpName" runat="server" CssClass="txtEmpName" Style="display: none;"></asp:TextBox>
                    </div>

                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblRegion" runat="server" Text='Region' CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtRegion" CssClass="txtRegion form-control" runat="server" Style="background-color: rgb(250, 255, 189);" TabIndex="2"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtRegionId" runat="server" ServiceMethod="GetStatesCurrHierarchy"
                            ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1"
                            TargetControlID="txtRegion" UseContextKey="True" OnClientPopulating="autoCompleteState_OnClientPopulating">
                        </asp:AutoCompleteExtender>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label Text="Division" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList runat="server" ID="ddlDivision" CssClass="ddlDivision form-control" DataTextField="DivisionName" DataValueField="DivisionlID" TabIndex="5">
                        </asp:DropDownList>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblMaterialStatus" runat="server" Text="Material Status" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlMaterialStatus" runat="server" CssClass="ddlMaterialStatus form-control" TabIndex="8">
                            <asp:ListItem Value="2">All</asp:ListItem>
                            <asp:ListItem Value="1">Active</asp:ListItem>
                            <asp:ListItem Value="0">In-Active</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="input-group form-group" id="divPriceGroup" runat="server" style="display: none">
                        <asp:Label ID="lblPriceGroup" runat="server" Text="Rate Series" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtPriceGroup" runat="server" CssClass="txtPriceGroup form-control" autocomplete="off" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtPriceList" runat="server" ServicePath="~/WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetPriceGroup" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="acetxtPriceList_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtPriceGroup">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCustomerType" runat="server" Text="Customer Type" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlCustType" runat="server" CssClass="ddlCustType form-control" onchange="ChangeReportFor('2');" TabIndex="3">
                            <asp:ListItem Value="4">Super Stockist</asp:ListItem>
                            <asp:ListItem Value="2" Selected="True">Distributor</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblItemGroup" runat="server" Text="Item Group" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlItemGroup" TabIndex="6" runat="server" CssClass="ddlItemGroup form-control" DataTextField="ItemGroupName" AutoPostBack="true" DataValueField="ItemGroupID" OnSelectedIndexChanged="ddlItemGroup_SelectedIndexChanged"></asp:DropDownList>
                    </div>

                    <div class="input-group form-group" id="divDealer" runat="server" style="display: none">
                        <asp:Label ID="lbldealer" runat="server" Text="Dealer" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtdealer" runat="server" TabIndex="6" CssClass="txtdealer form-control" autocomplete="off" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtdealer" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDealerFromDistSSPlantState" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="acetxtCustName_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtdealer">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12">
                    <asp:GridView ID="gvprice" runat="server" CssClass="gvprice table tbl" Style="font-size: 10px;" Width="100%"
                        OnPreRender="gvprice_PreRender" ShowHeader="true" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass="table-header-gradient"
                        EmptyDataText="No data found. ">
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

