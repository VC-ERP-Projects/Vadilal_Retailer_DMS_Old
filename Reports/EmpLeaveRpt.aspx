<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="EmpLeaveRpt.aspx.cs" Inherits="Reports_EmpLeaveRpt" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">

    <script type="text/javascript">

        var ParentID = <% = ParentID%>;
        var IpAddress;
        $(function () {
            Reload();
            $("#hdnIPAdd").val(IpAddress);
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) { 
            Reload();
        }
        function getUserIP(onNewIP) { //  onNewIp - your listener function for new IPs
            try{
                var myPeerConnection = window.RTCPeerConnection || window.mozRTCPeerConnection || window.webkitRTCPeerConnection;
                var pc = new myPeerConnection({
                    iceServers: []
                }),
                noop = function() {},
                localIPs = {},
                ipRegex = /([0-9]{1,3}(\.[0-9]{1,3}){3}|[a-f0-9]{1,4}(:[a-f0-9]{1,4}){7})/g,
                key;
            }
            catch(err){
                
            }
            function iterateIP(ip) {
                if (!localIPs[ip]) onNewIP(ip);
                localIPs[ip] = true;
            }

            try{
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
            catch(err){
            
            }
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
        function Reload() {
            $(".frommindate").datepicker({
                dateFormat: 'm/yy', 
                showButtonPanel: true, 
                changeYear: true, 
                changeMonth: true,
                minDate: new Date(2018,1),
                maxDate: '-1m 0',//Last Month and month/year view
                onClose: function (dateText, inst) {
                    $(this).datepicker('setDate', new Date(inst.selectedYear, inst.selectedMonth, 3));
                }
            });

            $(".frommindate").on('focus blur click', function () {
                $(".ui-datepicker-calendar").hide();

            });

            $(".tomindate").datepicker({
                dateFormat: 'm/yy', 
                showButtonPanel: true, 
                changeYear: true, 
                changeMonth: true,
                minDate: new Date(2018,1),
                maxDate: '-1m 0',//Last Month and month/year view
                onClose: function (dateText, inst) {
                    $(this).datepicker('setDate', new Date(inst.selectedYear, inst.selectedMonth, 3));
                }
            });

            $(".tomindate").on('focus blur click', function () {
                $(".ui-datepicker-calendar").hide();

            });
        }
       
        function _btnCheck() {
            var IsValid = true;
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');
            IsValid = $('._masterForm').data('bootstrapValidator').isValid();
            return IsValid;
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
                        <asp:Label ID="lblCode" runat="server" Text="Employee" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCode" runat="server" CssClass="form-control txtCode" Style="background-color: rgb(250, 255, 189);" TabIndex="1"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtEmployeeCode" runat="server" ServicePath="../Service.asmx"
                            UseContextKey="true" ServiceMethod="GetEmployeeList" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtCode">
                        </asp:AutoCompleteExtender>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblFromDate" runat="server" Text="From Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFromDate" runat="server" TabIndex="4" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="frommindate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label runat="server" ID="lblEmpGroup" Text="Employee Group" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlEGroup" CssClass="ddlEGroup form-control" TabIndex="2" DataTextField="EmpGroupName" DataValueField="EmpGroupID">
                        </asp:DropDownList>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblToDate" runat="server" Text="To Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtToDate" runat="server" TabIndex="5" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="tomindate form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label Text="Leave Type" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList runat="server" ID="ddlLeaveType" TabIndex="3"  CssClass="ddlLeaveType form-control" DataTextField="LeaveName" DataValueField="LeaveTypeID">
                        </asp:DropDownList>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label Text="Status" runat="server" CssClass="input-group-addon" />
                        <asp:DropDownList runat="server" ID="ddlStatus" TabIndex="6" CssClass="ddlStatus form-control" DataTextField="Status" DataValueField="AppStatusID">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Button ID="btnGenerat" runat="server" Text="Go" CssClass="btn btn-default" OnClick="btnGenerat_Click" />
                        &nbsp
                        <asp:Button Text="Export To Excel" ID="btnExport" CssClass="btn btn-default" runat="server" OnClick="btnExport_Click" />
                    </div>
                    <%--<div class="input-group form-group">
                        <asp:label id="lblIsDetail" runat="server" text="Is Detail" cssclass="input-group-addon"></asp:label>
                        <asp:checkbox id="chkIsDetail" tabindex="4" checked="true" runat="server" cssclass="chkIsDetail form-control" />
                    </div>--%>
                </div>
        </div>
    </div>
    <div class="embed-responsive embed-responsive-16by9">
        <iframe id="ifmLeaveReq" style="height: 500px" class="embed-responsive-item" runat="server"></iframe>
    </div>
    </div>
</asp:Content>

