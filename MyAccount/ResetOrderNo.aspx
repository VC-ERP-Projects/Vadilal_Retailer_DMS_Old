<%@ Page Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="ResetOrderNo.aspx.cs" Inherits="MyAccount_ResetOrderNo" MaintainScrollPositionOnPostback="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript" src="../Scripts/fixHeaderFooter.js"></script>
    <script type="text/javascript">

        var CustType = <% = CustType%>;
      
        function _btnCheck() {
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            return $('._masterForm').data('bootstrapValidator').isValid();
        }
      
        function hideModal() {
            $('#myCopyModal').modal('hide');
            $('.modal-backdrop').css('display', 'none');
        }

        function CloseModal() {
            $('#endDateSeq').prop('disabled',true);
        }
       
        $(function () {
            Relaod();
            var curYr = '<%=DateTime.Now.Year %>';
            var finalNextYrDate;
            finalNextYrDate = ("31/3/" + (parseInt(curYr) + 1)); 
            $('.todate1').datepicker("setDate", finalNextYrDate);
            //  $('.todate1').datepicker("option", "maxDate", finalNextYrDate); 
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            Relaod();
        }

        function Relaod() {
            $(".gvResetOrder").tableHeadFixer('71.5vh');
            $(".txtACT2Search").keyup(function () {
                var word = this.value;
                $(".gvResetOrder > tbody tr").each(function () {
                    if ($(this).find("td").text().toUpperCase().indexOf(word.toUpperCase()) >= 0)
                        $(this).show();
                    else
                        $(this).hide();
                });
            });
            $('.fromdate1').datepicker({
                numberOfMonths: 1,
                dateFormat: 'dd/mm/yy',
                changeMonth: true,
                changeYear: true,
                minDate: '0',
                onSelect: function (selected) {
                    var finalNextYrDate;
                    if (selected.split("/").length = 3) {
                        finalNextYrDate = ("31/3/" + (parseInt(selected.split("/")[2]) + 1));
                        $('.todate1').datepicker("option", "minDate", selected);
                        // $('.todate1').datepicker("option", "maxDate", finalNextYrDate);
                        $('.todate1').datepicker("setDate", finalNextYrDate);
                    }
                }
            });
           
     
            $('.todate1').datepicker({
                numberOfMonths: 1,
                dateFormat: 'dd/mm/yy',
                changeMonth: true,
                changeYear: true,
                minDate: '0'
            });
              
        }

        function reloadPage(){
            location.reload();

        }
    </script>
    <style>
        .table > tbody > tr > td {
            padding: 3px 8px;
        }

        .btn {
            padding-top: 3px;
            padding-right: 5px;
            padding-left: 5px;
            padding-bottom: 3px;
        }

        #ui-datepicker-div {
            z-index: 9999 !important;
        }

        .modal-body {
            padding: 0;
        }

        #myCopyModal .btn-default {
            display: block;
            margin: 0 auto;
        }

        .lblCenter {
            text-align: center;
        }

        .lblRight {
            text-align: right;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body ">
            <div class="row _masterForm">
                <div class="col-lg-4">
                    <div class="input-group form-group" runat="server" id="divDistributor">
                        <asp:Label ID="lblCustomer" runat="server" Text="Customer" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCustCode" runat="server" TabIndex="1" CssClass="txtCustCode form-control" Style="background-color: rgb(250, 255, 189);" OnTextChanged="txtCustCode_TextChanged" AutoPostBack="true" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetALLCustomer" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCustCode" ContextKey="2,4">
                        </asp:AutoCompleteExtender>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromDate" runat="server" Text="From Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromDate" autocomplete="off" runat="server" TabIndex="4" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="fromdate1 form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblPrefix" Text="Prefix" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtPrefix" autocomplete="off" runat="server" TabIndex="2" CssClass="form-control" data-bv-notempty="false" data-bv-notempty-message="Field is required"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtToDate" autocomplete="off" runat="server" TabIndex="5" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="todate1 form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblType" Text="Transaction Type" CssClass="input-group-addon" runat="server"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlType" TabIndex="3" CssClass="form-control">
                            <asp:ListItem Text="Purchase Order" Value="P" />
                            <asp:ListItem Text="Purchase Receipt" Value="PC" />
                            <asp:ListItem Text="Sales Order" Value="O" />
                            <asp:ListItem Text="Tax Sales" Value="T" />
                            <asp:ListItem Text="Purchase Return " Value="PR" />
                            <asp:ListItem Text="Sales Return" Value="SR" />
                            <asp:ListItem Text="Consume" Value="C" />
                            <asp:ListItem Text="Wastage" Value="W" />
                        </asp:DropDownList>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblOrderNo" Text="Last Transaction Nos." CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtOrderNo" autocomplete="off" runat="server" TabIndex="6" CssClass="form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                    </div>
                </div>
                <div class="button-wrapper">
                    <div class="col-lg-8">
                        <asp:Button ID="btnSubmit" runat="server" TabIndex="7" Text="Submit" CssClass="btn btn-default" OnClientClick="return _btnCheck();" OnClick="btnSubmit_Click" />
                        &nbsp
                        <asp:Button ID="btnCancel" runat="server" Text="Cancel" TabIndex="8" CssClass="btn btn-default" OnClientClick="reloadPage()" />
                        &nbsp
                         <asp:LinkButton ID="btnCopy" runat="server" Text="Copy" TabIndex="9" CssClass="btn btn-default" OnClick="btnCopy_Click" />
                        &nbsp                   
                    </div>
                    <div class="col-lg-4" style="text-align: right;">
                        Search<asp:TextBox runat="server" ID="txtACT2Search" CssClass="txtACT2Search" Style="float: right; background-image: url('../Images/Search.png'); background-position: right; margin-left: 0px; background-repeat: no-repeat" />
                    </div>
                </div>
            </div>
            <asp:GridView runat="server" ID="gvResetOrder" CssClass="table gvResetOrder" ShowHeader="true" AutoGenerateColumns="false"
                OnRowCommand="gvResetOrder_RowCommand" OnPreRender="gvResetOrder_PreRender" HeaderStyle-CssClass="table-header-gradient"
                FooterStyle-CssClass="table-header-gradient" EmptyDataText="No Data Found." Font-Size="11px">
                <Columns>
                    <asp:TemplateField HeaderText="Sr." HeaderStyle-Width="3px" HeaderStyle-CssClass="lblRight" ItemStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <%#Container.DataItemIndex+1 %>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField HeaderText="From Date" DataField="FromDate" DataFormatString="{0:dd-MMM-yy}" HeaderStyle-Width="30px" ItemStyle-HorizontalAlign="Center">
                        <HeaderStyle CssClass="lblCenter" />
                    </asp:BoundField>
                    <asp:BoundField HeaderText="To Date" DataField="ToDate" DataFormatString="{0:dd-MMM-yy}" HeaderStyle-Width="30px" ItemStyle-HorizontalAlign="Center">
                        <HeaderStyle CssClass="lblCenter" />
                    </asp:BoundField>
                    <asp:BoundField HeaderText="Transaction Type" DataField="Type" HeaderStyle-Width="40px" />
                    <asp:BoundField HeaderText="Prefix" DataField="Prefix" HeaderStyle-Width="25px" />
                    <asp:BoundField HeaderText="Last Nos." HeaderStyle-CssClass="lblRight" ItemStyle-HorizontalAlign="Right" DataField="RorderNo" HeaderStyle-Width="25px" />
                    <asp:BoundField HeaderText="Created Date" DataField="CreatedDate" DataFormatString="{0:dd-MMM-yy HH:mm}" HeaderStyle-Width="40px" ItemStyle-HorizontalAlign="Center">
                        <HeaderStyle CssClass="lblCenter" />
                    </asp:BoundField>
                    <asp:BoundField HeaderText="Created By" DataField="CreatedBy" HeaderStyle-Width="90px" />
                    <asp:BoundField HeaderText="Updated Date" DataField="UpdatedDate" DataFormatString="{0:dd-MMM-yy HH:mm}" HeaderStyle-Width="40px" ItemStyle-HorizontalAlign="Center">
                        <HeaderStyle CssClass="lblCenter" />
                    </asp:BoundField>
                    <asp:BoundField HeaderText="Updated By" DataField="UpdatedBy" HeaderStyle-Width="55px" />
                    <asp:TemplateField HeaderText="Edit" ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="15px">
                        <ItemTemplate>
                            <asp:Button Font-Size="11px" ID="btnEdit" runat="server" Text="Edit" CssClass="btn btn-default" CommandName="EditMode" CommandArgument='<%#Eval("SequenceID")+ "," + Eval("ParentID") %>'></asp:Button>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Delete" ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="15px">
                        <ItemTemplate>
         					<asp:LinkButton Font-Size="11px" ID="btnDelete" runat="server" CssClass="btn btn-default" OnClientClick="return confirm('Are you sure you want to delete this sequence?');" CommandName="DeleteMode" CommandArgument='<%#Eval("SequenceID")+ "," + Eval("ParentID") %>'>Delete </asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </div>
    <!-- Modal -->
    <!-- Bootstrap Modal Dialog -->
    <div class="modal fade" id="myCopyModal" role="dialog" aria-labelledby="myCopyModalLabel" aria-hidden="true" tabindex='-1'>
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" onclick="CloseModal()" aria-hidden="true">&times;</button>
                    <h4 class="modal-title">
                        <asp:Label ID="lblModalTitle" runat="server" Text="Number Setting (Yearly)"></asp:Label></h4>
                </div>
                <div class="modal-body">
                    <div class="col-lg-6">
                        <div class="input-group form-group">
                            <asp:Label ID="lblfromDateSeq" runat="server" Text="From Date" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="fromDateSeq" TabIndex="1" runat="server" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="fromdate form-control" ClientIDMode="Static"></asp:TextBox>
                        </div>
                    </div>
                    <div class="col-lg-6">
                        <div class="input-group form-group">
                            <asp:Label ID="lblendDateSeq" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="endDateSeq" runat="server" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="todate form-control" ClientIDMode="Static"></asp:TextBox>
                        </div>
                    </div>

                    <div class="col-lg-12">
                        <div class="input-group form-group" runat="server" id="div1">
                            <asp:Label runat="server" Text="Customer" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtPopupCustCode" runat="server" CssClass="form-control" disabled="disabled"></asp:TextBox>
                        </div>
                    </div>
                    <div class="col-lg-12">
                        <asp:GridView runat="server" ID="gvSeqCopy" CssClass="table" ShowHeader="true" AutoGenerateColumns="false"
                            OnPreRender="gvSeqCopy_PreRender" HeaderStyle-CssClass="table-header-gradient"
                            FooterStyle-CssClass="table-header-gradient" EmptyDataText="No Data Found." Font-Size="11px">
                            <Columns>
                                <asp:TemplateField HeaderText="Sr." HeaderStyle-Width="6%" HeaderStyle-CssClass="lblRight" ItemStyle-HorizontalAlign="Right">
                                    <ItemTemplate>
                                        <%#Container.DataItemIndex+1 %>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Transaction Type" >
                                    <ItemTemplate>
                                        <asp:Label ID="lblTrType" Text='<%# Eval("TypeDesc") %>' runat="server"></asp:Label>
                                        <asp:HiddenField ID="lblTypeCode" runat="server" Value='<%#Eval("Type") %>'></asp:HiddenField>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Existing Prefix"  >
                                    <ItemTemplate>
                                        <asp:Label ID="txtExType" Text='<%# Eval("Prefix") %>' runat="server"></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="New Prefix">
                                    <ItemTemplate>
                                        <asp:TextBox ID="txtNewPrefix" CssClass="txtNewPrefix" runat="server" Width="100%" Text='<%#Eval("NewPrefix") %>'></asp:TextBox>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Last Nos." HeaderStyle-Width="8%" HeaderStyle-CssClass="lblRight" ItemStyle-HorizontalAlign="Right">
                                    <ItemTemplate>
                                        <asp:Label ID="lblNumber" runat="server" Text='0'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
                <div class="modal-footer">
                    <asp:Button ID="saveData" CommandName="saveData" runat="server" Text="Submit" CssClass="btn btn-default" OnClick="btnSaveData_Click" />
                </div>
            </div>
        </div>
    </div>
    <!-- /.modal -->
</asp:Content>


