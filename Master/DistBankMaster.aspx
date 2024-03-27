<%@ Page Title="" Language="C#" MasterPageFile="~/MainMaster.master" AutoEventWireup="true" CodeFile="DistBankMaster.aspx.cs" Inherits="Master_DistBankMaster" %>

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

        var Version = 'QA';
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

        $(document).ready(function () {


            $(document).on('keyup', '.txtBankName', function () {
                var textValue = $(this).val();
                $('#txtBankName').autocomplete({
                    source: function (request, response) {
                        $.ajax({
                            type: "POST",
                            url: 'DistBankMaster.aspx/SearchBank',
                            dataType: "json",
                            data: "{ 'prefixText': '" + (textValue != '' ? textValue : '*') + "'}",
                            contentType: "application/json; charset=utf-8",
                            success: function (data) {
                                response($.map(data.d, function (item) {
                                    return {
                                        label: item.Text,
                                        value: item.Text,
                                        id: item.Value
                                    };
                                }))
                            },
                            error: function (XMLHttpRequest, textStatus, errorThrown) {
                            }
                        });
                    },
                    //position: {
                    //    my: 'left top',
                    //    at: 'right top',
                    //    collision: 'flip flip',
                    //    of: $('#txtBankName'),
                    //    using: function (obj, info) {
                    //        if (info.vertical != "top") {
                    //            $(this).addClass("flipped");
                    //        } else {
                    //            $(this).removeClass("flipped");
                    //        }
                    //        if (info.horizontal != "left") {
                    //            $(this).addClass("flipped");
                    //        } else {
                    //            $(this).removeClass("flipped");
                    //        }
                    //        $(this).css({
                    //            left: obj.left + 'px',
                    //            top: obj.top + 'px'
                    //        });
                    //    }
                    //},
                    select: function (event, ui) {

                        $('#txtBankName').val(ui.item.value + " ");
                        $('#hdnBankId').val(ui.item.value.split("#")[1].trim());
                    },
                    change: function (event, ui) {
                        if (!ui.item) {

                        }
                    },
                    minLength: 1
                });
            });

            $('.txtBankName').on('autocompleteselect', function (e, ui) {
                $('#txtBankName').val(ui.item.value);
            });


            $('.txtBankName').on('change keyup', function () {
                if ($('#txtBankName').val() == "") {
                    $('#hdnBankId').val(0);
                }
            });


            $('.txtBankName').on('blur', function (e, ui) {

                if ($('#txtBankName').val().trim() != "") {
                    if ($('#txtBankName').val().indexOf('#') == -1) {
                        ModelMsg("Select Proper Bank Name", 3);
                        $('#txtBankName').val("");
                        $('#hdnBankId').val('0');
                        return;
                    }
                    var txt = $('#txtBankName').val().trim();
                    if (txt == "undefined" || txt == "") {
                        //ModelMsg("Enter Item Code Or Name", 3);
                        return false;
                    }
                }
            });
        });
        function Cancel() {
            window.location = "../Master/DistBankMaster.aspx";
        }
        function isNumber(evt) {
            evt = (evt) ? evt : window.event;
            var charCode = (evt.which) ? evt.which : evt.keyCode;
            if (charCode > 31 && (charCode < 48 || charCode > 57)) {
                return false;
            }

            return true;
        }
        // Function to validate the
        // IFSC_Code 

        //isValid_IFSC_Code(str1)


        function isValid_IFSC_Code(ifsc_Code) {

            // Regex to check valid
            // ifsc_Code 
            let regex = new RegExp(/^[A-Z]{4}0[A-Z0-9]{6}$/);

            // if ifsc_Code
            // is empty return false
            if (ifsc_Code == null) {
                return "false";
            }

            // Return true if the ifsc_Code
            // matched the ReGex
            if (regex.test(ifsc_Code) == true) {
                return "true";
            }
            else {
                return "false";
            }
        }
    </script>
    <style>
        .input-group-addon,.ui-autocomplete,.form-control {
            font-size: 12px !important;
            font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <asp:HiddenField runat="server" ID="hdnIPAdd" ClientIDMode="Static" Value="0" />
    <input type="hidden" class="hdnUserName" id="hdnUserName" runat="server" />
    <div class="panel">
        <div class="panel-body ">
            <div class="row _masterForm">
                <div class="col-lg-12">
                    <div class="col-lg-2">
                    </div>
                    <div class="col-lg-6">
                        <div class="input-group form-group">
                            <asp:Label ID="Label1" runat="server" Text="Account No" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtAccountNo" TabIndex="1" runat="server" MaxLength="18" CssClass="txtAccountNo form-control" onkeypress='return isNumber(event)' ClientIDMode="Static"></asp:TextBox>
                        </div>
                    </div>
                    <div class="col-lg-4">
                    </div>
                </div>
                <div class="col-lg-12">
                    <div class="col-lg-2">
                    </div>
                    <div class="col-lg-6">
                        <div class="input-group form-group">
                            <asp:Label ID="Label2" runat="server" Text="IFSC Code" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtIFSCCode" runat="server" TabIndex="2" MaxLength="15" CssClass="txtIFSCCode form-control" ClientIDMode="Static"></asp:TextBox>
                        </div>
                    </div>

                </div>
                <div class="col-lg-12">
                    <div class="col-lg-2">
                    </div>
                    <div class="col-lg-6">
                        <div class="input-group form-group">
                            <asp:Label ID="lblCategoryCode" runat="server" Text="Bank Name" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtBankName" TabIndex="3" runat="server" CssClass="txtBankName form-control" ClientIDMode="Static"></asp:TextBox>
                            <asp:HiddenField ID="hdnBankId" runat="server" />
                        </div>
                    </div>

                    <div class="col-lg-4">
                    </div>
                </div>
                <div class="col-lg-12">
                    <div class="col-lg-2">
                    </div>
                    <div class="col-lg-6">
                        <div class="input-group form-group">
                            <asp:Label ID="lblDiscription" runat="server" Text="Branch Name" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtBranchName" runat="server" TabIndex="4" MaxLength="30" CssClass="txtBranchName form-control" ClientIDMode="Static"></asp:TextBox>
                        </div>
                    </div>
                    <div class="col-lg-4">
                    </div>
                </div>
                <div class="col-lg-12" style="display:none;">
                    <div class="col-lg-2">
                    </div>
                    <div class="col-lg-6">
                        <div class="input-group form-group">
                            <asp:Label ID="Label3" runat="server" Text="Jurisdiction" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtJurisdiction" runat="server" TabIndex="4" MaxLength="50" CssClass="txtJurisdiction form-control" ClientIDMode="Static"></asp:TextBox>
                        </div>
                    </div>
                    <div class="col-lg-4">
                    </div>
                </div>
                <div class="col-lg-12">
                    <div class="col-lg-2">
                    </div>
                    <div class="col-lg-3">
                        <div class="input-group form-group">
                            <asp:Label runat="server" ID="lblUpdateBy" Text="Update By" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox runat="server" ID="txtUpdateBy" CssClass="form-control" disabled="disabled" />
                        </div>
                    </div>
                    <div class="col-lg-3">
                        <div class="input-group form-group">
                            <asp:Label runat="server" ID="lblUpdatedDate" Text="Updated Date" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox runat="server" ID="txtUpdatedDate" CssClass="form-control" disabled="disabled" />
                        </div>
                    </div>
                    <div class="col-lg-4">
                    </div>
                </div>
                 
                <div class="col-lg-12">
                    <div class="col-lg-3">
                    </div>
                    <div class="col-lg-6">
                        <asp:Button ID="saveData" CommandName="saveData" TabIndex="5" runat="server" Text="Submit" CssClass="btn btn-primary" OnClick="saveData_Click" />
                        <asp:Button ID="btnCancel" runat="server" TabIndex="6" OnClientClick="Cancel();" Text="Cancel" CssClass="btn btn-default" />
                    </div>

                </div>
            </div>
        </div>
    </div>
</asp:Content>

