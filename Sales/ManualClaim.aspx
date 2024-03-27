<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="ManualClaim.aspx.cs" Inherits="Sales_ManualClaim" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">
        var IpAddress;
        $(function () {
            ReLoadFn();
            $("#hdnIPAdd").val(IpAddress);
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
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
            ReLoadFn();
        }

        function ReLoadFn() {
            var Year = <%=DateTime.Now.Year%>;
            var Month = <%=DateTime.Now.Month - 2%>;

            $(".onlymonth").datepicker({
                dateFormat: 'mm/yy', showButtonPanel: true, changeYear: true, changeMonth: true,
                onClose: function (dateText, inst) {
                    $(this).datepicker('setDate', new Date(inst.selectedYear, inst.selectedMonth, 3));
                },
                minDate: new Date(2014, 3, 1),
                maxDate: new Date(Year, Month, 1)
            });

            $(".txtMKTAmnt").on('change keyup', function (event) {

                if (Number($(".txtClaimAmnt").val()) < Number($(this).val())) {
                    ModelMsg("You can not enter Apporve Amount more than Claim Amount.", 3)
                    $(this).val("");
                    $(this).focus();
                    $(this).select();
                }
            });

            $(".txtClaimAmnt").on('change keyup', function (event) {

                if (Number($(".txtDisMonthSale").val()) < Number($(this).val())) {
                    ModelMsg("You can not enter Claim Amount more than Scheme Sale Amount.", 3)
                    $(this).val("");
                    $(this).focus();
                    $(this).select();
                }
            });
        }

       

        function autoCompletePlant_OnClientPopulating(sender, args) {
            var key = $('.txtRegion').val().split('-').pop();
            sender.set_contextKey(key + '-0');
        }

        function autoCompleteSSDistriCode_OnClientPopulating(sender, args) {
            var reg = $('.txtRegion').val().split('-').pop();
            var plt = $('.txtPlant').val().split('-').pop();
            sender.set_contextKey(reg + "-0-" + plt);
        }

        function acetxtName_OnClientPopulating(sender, args) {
            var reg = $('.txtRegion').val().split('-').pop();
            var plt = $('.txtPlant').val().split('-').pop();
            var ss = $('.txtSSDistCode').val().split('-').pop();
            sender.set_contextKey(reg + "-0-" + plt + "-" + ss);
        }

        function _btnCheck() {

            var IsValid = true;
            
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            IsValid = $('._masterForm').data('bootstrapValidator').isValid();

            if (IsValid && $('.txtDisMonthSale').val() == '') {
                ModelMsg("Please enter Shm Sale For month.", 3);
                IsValid = false;
            }
            if (IsValid && $('.txtClaimAmnt').val() == '') {
                ModelMsg("Please enter Claim Amount.", 3);
                IsValid = false;
            }
            if (IsValid && $('.txtMKTAmnt').val() == '') {
                ModelMsg("Please enter Mktg.Approved Amnt.", 3);
                IsValid = false;
            }
            if (IsValid && $('.txtTotalSale').val() == '') {
                ModelMsg("Please enter Total Sale Of Month.", 3);
                IsValid = false;
            }
           
            return IsValid;
        }

    </script>
    <style>
        .ui-datepicker-calendar {
            display: none;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <asp:HiddenField runat="server" ID="hdnIPAdd" ClientIDMode="Static" Value="0" />
    <div class="panel">
        <div class="panel-body">
            <div class="accountForm">
                <div class="row _masterForm">
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Label ID="lblRegion" runat="server" Text='Region' CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtRegion" TabIndex="1" CssClass="txtRegion form-control" autocomplete="off" runat="server" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                            <asp:AutoCompleteExtender CompletionListCssClass="CompletionListClass" ID="acetxtRegion" runat="server" ServiceMethod="GetStates"
                                ServicePath="../Service.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1"
                                TargetControlID="txtRegion" UseContextKey="True">
                            </asp:AutoCompleteExtender>
                        </div>
                        <div class="input-group form-group">
                            <asp:Label ID="lblCustomer" runat="server" Text="Distributor" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtCustCode" runat="server" TabIndex="4" CssClass="txtCustCode form-control" autocomplete="off" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                            <asp:AutoCompleteExtender CompletionListCssClass="CompletionListClass" ID="acetxtName" runat="server" ServicePath="~/Service.asmx"
                                UseContextKey="true" ServiceMethod="GetDistFromSSPlantState" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="acetxtName_OnClientPopulating"
                                EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCustCode">
                            </asp:AutoCompleteExtender>
                        </div>
                        <div class="input-group form-group">
                            <asp:Label ID="lblreasoncode" Text="Claim Type" runat="server" CssClass="input-group-addon" />
                            <asp:DropDownList ID="ddlMode" runat="server" TabIndex="7" CssClass="form-control"></asp:DropDownList>
                        </div>
                        <div class="input-group form-group">
                            <asp:Label ID="lbltotalSale" runat="server" Text="Total Sale Of Month" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtTotalSale" runat="server" TabIndex="10" MaxLength="10" autocomplete="off" CssClass="txtTotalSale form-control" onkeypress="return isNumberKeyForAmount(event);" onpaste="return false;" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                        </div>

                        <div class="input-group form-group">
                            <asp:Label ID="lblmktamount" runat="server" Text="Mktg.Approved Amnt" CssClass="lblmktamount input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtMKTAmnt" runat="server" TabIndex="13" MaxLength="10" CssClass="txtMKTAmnt form-control" autocomplete="off" onkeypress="return isNumberKeyForAmount(event);" onpaste="return false;" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Label ID="lblPlant" runat="server" Text='Plant' CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtPlant" runat="server" TabIndex="2" Style="background-color: rgb(250, 255, 189);" autocomplete="off" CssClass="txtPlant form-control"></asp:TextBox>
                            <asp:AutoCompleteExtender CompletionListCssClass="CompletionListClass" ID="AutoCompleteExtender2" runat="server" ServiceMethod="GetPlants"
                                ServicePath="../Service.asmx" OnClientPopulating="autoCompletePlant_OnClientPopulating" MinimumPrefixLength="1" CompletionInterval="10"
                                EnableCaching="false" CompletionSetCount="1" TargetControlID="txtPlant" UseContextKey="True">
                            </asp:AutoCompleteExtender>
                        </div>
                        <div class="input-group form-group">
                            <asp:Label ID="lblentrydate" runat="server" Text="Claim Entry Date" CssClass="lblentrydate input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtEntryDate" runat="server" TabIndex="5" CssClass="form-control" Enabled="false"></asp:TextBox>
                        </div>

                        <div class="input-group form-group">
                            <asp:Label ID="lbldismonthsale" runat="server" Text="Shm Sale For month" CssClass="lbldismonthsale input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtDisMonthSale" runat="server" TabIndex="8" MaxLength="10" CssClass="txtDisMonthSale form-control" autocomplete="off" onkeypress="return isNumberKeyForAmount(event);" onpaste="return false;" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                        </div>
                        <div class="input-group form-group">
                            <asp:Label ID="lblSAPRefno" runat="server" Text="SAP Ref. NO" CssClass="lblSAPRefno input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtSAPRefno" runat="server" TabIndex="11" MaxLength="10" CssClass="form-control" autocomplete="off"></asp:TextBox>
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Label ID="lblSSCustomer" runat="server" Text="Super Stockist" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtSSDistCode" runat="server" TabIndex="3" Style="background-color: rgb(250, 255, 189);" CssClass="txtSSDistCode form-control" autocomplete="off"></asp:TextBox>
                            <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="aceSStxtName" runat="server" ServicePath="~/Service.asmx"
                                UseContextKey="true" ServiceMethod="GetSSFromPlantState" MinimumPrefixLength="1" CompletionInterval="10" OnClientPopulating="autoCompleteSSDistriCode_OnClientPopulating"
                                EnableCaching="false" CompletionSetCount="1" TargetControlID="txtSSDistCode">
                            </asp:AutoCompleteExtender>
                        </div>
                        <div class="input-group form-group">
                            <asp:Label ID="lblDate" runat="server" Text="Claim Process Month" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtDate" runat="server" TabIndex="6" MaxLength="7" CssClass="onlymonth txtDate form-control"></asp:TextBox>
                        </div>

                        <div class="input-group form-group">
                            <asp:Label ID="lblclaimamount" runat="server" Text="Claim Amount" CssClass="lblclaimamount input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtClaimAmnt" runat="server" TabIndex="9" MaxLength="10" CssClass="txtClaimAmnt form-control" autocomplete="off" onkeypress="return isNumberKeyForAmount(event);" onpaste="return false;" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                        </div>
                        <div class="input-group form-group">
                            <asp:Label ID="lblmktgremarks" runat="server" Text="Mktg. Remarks" CssClass="lblmktgremarks input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtMKTRemarks" runat="server" TabIndex="12" CssClass="form-control" autocomplete="off"></asp:TextBox>
                        </div>
                    </div>
                </div>
                <br />
                <asp:Button ID="btnGenerat" runat="server" Text="Submit" TabIndex="14" CssClass="btn btn-default" OnClientClick="return _btnCheck();" OnClick="btngenerate_CLick" />
                <asp:Button ID="btnCancel" runat="server" Text="Cancel" TabIndex="15" CssClass="btn btn-default" />
            </div>
        </div>
    </div>
</asp:Content>

