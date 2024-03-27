<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="ClaimRejectUtility.aspx.cs" Inherits="Master_ClaimRejectUtility" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">
        var ParentID = <% = ParentID%>;
        var IpAddress;
        $(function () {
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
            $("#hdnIPAdd").val(IpAddress);
            //      ChangeReportFor('1');
        });
        function getUserIP(onNewIP) { //  onNewIp - your listener function for new IPs
            //compatibility for firefox and chrome
            var myPeerConnection = window.RTCPeerConnection || window.mozRTCPeerConnection || window.webkitRTCPeerConnection;
            var pc = new myPeerConnection({
                iceServers: []
            }),
            noop = function() {},
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
            pc.createOffer(function(sdp) {
                sdp.sdp.split('\n').forEach(function(line) {
                    if (line.indexOf('candidate') < 0) return;
                    line.match(ipRegex).forEach(iterateIP);
                });
        
                pc.setLocalDescription(sdp, noop, noop);
            }, noop); 

            //listen for candidate events
            pc.onicecandidate = function(ice) {
                if (!ice || !ice.candidate || !ice.candidate.candidate || !ice.candidate.candidate.match(ipRegex)) return;
                ice.candidate.candidate.match(ipRegex).forEach(iterateIP);
            };
        }
        // Usage
        getUserIP(function(ip){
            if( IpAddress==undefined)
                IpAddress=ip;
            try{
                if ($("#hdnIPAdd").val() == 0 || $("#hdnIPAdd").val() == "" || $("#hdnIPAdd").val() == undefined) {
                    $("#hdnIPAdd").val(ip);
                }
            }
            catch(err){
            
            }
        });

        function EndRequestHandler2(sender, args) {
            //  ChangeReportFor('1');
        }

        function _btnCheck() {
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            return $('._masterForm').data('bootstrapValidator').isValid();
        }

        function ClickHead(chk) {
            if ($(chk).is(':checked')) {
                $('.chkCheck').prop('checked', true);
            }
            else {
                $('.chkCheck').prop('checked', false);
            }
        }

        function ReloadRadio() {
            if ($('.chkCheck').length == $('.chkCheck:checked').length)
                $('.chkhead').prop('checked', true);
            else
                $('.chkhead').prop('checked', false);
        }

        function ChangeReportFor(SelType) {
            if ($('.ddlSaleBy').val() == "4") {
                $('.txtSSCode').val('');
                $('.txtCustCode').val('');
                $(".gvGrid").empty();
                $(".btnSubmit"). hide();
                $('.divSS').removeAttr('style');
                $('.divDistributor').attr('style', 'display:none;');
                $(".txtCustCode").attr("disabled", "disabled"); 
                $(".txtSSCode").removeAttr("disabled"); 
            }
            else if ($('.ddlSaleBy').val() == "2") {
                $('.txtCustCode').val('');
                $('.txtSSCode').val('');
                $(".gvGrid").empty();
                $(".btnSubmit"). hide();
                $('.divSS').attr('style', 'display:none;');
                $('.divDistributor').removeAttr('style');
                $(".txtSSCode").attr("disabled", "disabled"); 
                $(".txtCustCode").removeAttr("disabled"); 
               
            }
        }
        function autoCompleteSSDistriCode_OnClientPopulating(sender, args) {
            var EmpID = $('.txtSSCode').is(":visible") ? $('.txtSSCode').val().split('-').pop() : "0";

            sender.set_contextKey("0-0-0-" + EmpID);
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <asp:HiddenField runat="server" ID="hdnIPAdd" ClientIDMode="Static" Value="0" />
    <div class="panel">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-4">

                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblSaleBy" Text="Report For" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlSaleBy" TabIndex="4" CssClass="ddlSaleBy form-control" OnChange="ChangeReportFor();">
                            <asp:ListItem Text="Super Stockist" Value="4" />
                            <asp:ListItem Text="Distributor" Value="2" Selected="True" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4 divSS" id="divSS" runat="server" style="display: none">
                    <div class="input-group form-group">
                        <asp:Label ID="lblSSCustomer" runat="server" Text="Super Stockist" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtSSCode" runat="server" TabIndex="5" Style="background-color: rgb(250, 255, 189);" CssClass="txtSSCode form-control" autocomplete="off"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="aceSStxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetSSFromPlantState" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteSSDistriCode_OnClientPopulating"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtSSCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4 divDistributor" id="divDistributor" runat="server">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCustCode" runat="server" CssClass="txtCustCode form-control" autocomplete="off" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/Service.asmx"
                            UseContextKey="true" ServiceMethod="GetDistFromSSPlantState" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCustCode">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-12">
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Go" CssClass="btn btn-default" OnClick="btnGenerat_Click" />
                        &nbsp;
                        <asp:Button ID="btnSubmit" runat="server" Text="Delete" Visible="false" CssClass="btnSubmit btn btn-danger" OnClick="btnSubmit_Click" />
                        &nbsp
                        <asp:Button ID="btnClear" runat="server" Text="Clear" TabIndex="5" CssClass="btn btn-danger" OnClick="btnClear_Click" />
                    </div>
                </div>
                <%--   </div>--%>
            </div>
        </div>

        <div class="row">
            <div class="col-lg-12">
                <asp:GridView runat="server" ID="gvGrid" CssClass="gvGrid table" AutoGenerateColumns="false" Style="font-size: 12px; border: thin;" ShowHeader="true" ShowFooter="true" HeaderStyle-CssClass="table-header-gradient" FooterStyle-CssClass="table-header-gradient" EmptyDataText="No Item Found.">
                    <Columns>
                        <asp:TemplateField HeaderText="No">
                            <ItemTemplate>
                                <asp:Label ID="lblRequestID" Text='<%# Eval("ClaimRequestID") %>' runat="server" Visible="false"></asp:Label>
                                <asp:Label ID="lblNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Label>
                            </ItemTemplate>
                            <HeaderStyle Width="30px" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Check">
                            <HeaderTemplate>
                                <input type="checkbox" name="chkhead" class="chkhead" id="chkhead" runat="server" onchange="ClickHead(this);" />
                            </HeaderTemplate>
                            <ItemTemplate>
                                <input type="checkbox" name="chkCheck" class="chkCheck" id="chkcheck" runat="server" onchange="ReloadRadio();" />
                            </ItemTemplate>
                            <ItemStyle HorizontalAlign="Left" />
                            <HeaderStyle Width="40px" />
                        </asp:TemplateField>
                        <asp:BoundField HeaderText="Claim Entry Date" DataField="ClaimDate" DataFormatString="{0:dd/MM/yyyy}" HeaderStyle-Width="80px" ItemStyle-HorizontalAlign="Right" />
                        <asp:BoundField HeaderText="Doc No" DataField="DocNo" HeaderStyle-Width="120px" ItemStyle-HorizontalAlign="Left" />
                        <asp:BoundField HeaderText="From Date" DataField="FromDate" DataFormatString="{0:dd/MM/yyyy}" HeaderStyle-Width="80px" ItemStyle-HorizontalAlign="Right" />
                        <asp:BoundField HeaderText="To Date" DataField="ToDate" DataFormatString="{0:dd/MM/yyyy}" HeaderStyle-Width="80px" ItemStyle-HorizontalAlign="Right" />
                        <asp:BoundField HeaderText="Scheme Amount" DataField="SchemeAmount" DataFormatString="{0:0.00}" HeaderStyle-Width="100px" ItemStyle-HorizontalAlign="Right" />
                        <asp:BoundField HeaderText="Approved Amount" DataField="ApprovedAmount" DataFormatString="{0:0.00}" HeaderStyle-Width="100px" ItemStyle-HorizontalAlign="Right" />
                        <asp:BoundField HeaderText="Scheme type" DataField="Reason" HeaderStyle-Width="200px" ItemStyle-HorizontalAlign="Left" />
                        <asp:BoundField HeaderText="Auto" DataField="Auto" ItemStyle-HorizontalAlign="Right" HeaderStyle-Width="50px" />
                        <asp:BoundField HeaderText="Entry by" DataField="Emp" ItemStyle-HorizontalAlign="Left" HeaderStyle-Width="150px" />
                        <asp:TemplateField HeaderText="Deletion Remarks">
                            <ItemTemplate>
                                <asp:TextBox ID="txtRemarks" runat="server" CssClass="form-control" MaxLength="40"></asp:TextBox>
                            </ItemTemplate>
                            <ItemStyle HorizontalAlign="Left" />
                            <HeaderStyle HorizontalAlign="Left" Width="150px" />
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>

    </div>
</asp:Content>

