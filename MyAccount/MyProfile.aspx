<%@ Page Language="C#" MasterPageFile="~/MainMaster.master" AutoEventWireup="true" CodeFile="MyProfile.aspx.cs" Inherits="MyAccount_MyProfile" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../Scripts/colorbox/colorbox.css" rel="stylesheet" />
    <script type="text/javascript" src="../Scripts/colorbox/jquery.colorbox-min.js"></script>

    <script type="text/javascript">

        $(function () {

            $('.accountForm')
                .bootstrapValidator({
                    // Only disabled elements are excluded
                    // The invisible elements belonging to inactive tabs must be validated
                    excluded: [':disabled'],
                    feedbackIcons: {
                        valid: 'glyphicon glyphicon-ok',
                        invalid: 'glyphicon glyphicon-remove',
                        validating: 'glyphicon glyphicon-refresh'
                    },
                    live: 'enabled',
                    trigger: null
                })
                // Called when a field is invalid
                .on('error.field.bv', function (e, data) {
                    // data.element --> The field element
                    // alert('errr');
                    var $tabPane = data.element.parents('.tab-pane'),
                        tabId = $tabPane.attr('id');

                    $('a[href="#' + tabId + '"][data-toggle="tab"]')
                        .parent()
                        .find('i')
                        .removeClass('fa-check')
                        .addClass('fa-times');

                    data.bv.disableSubmitButtons(false);

                })
                // Called when a field is valid
                .on('success.field.bv', function (e, data) {
                    // data.bv      --> The BootstrapValidator instance
                    // data.element --> The field element
                    //alert(data.element.parents('.tab-pane'));
                    var $tabPane = data.element.parents('.tab-pane'),
                        tabId = $tabPane.attr('id'),
                        $icon = $('a[href="#' + tabId + '"][data-toggle="tab"]')
                                    .parent()
                                    .find('i')
                                    .removeClass('fa-check fa-times');

                    // Check if the submit button is clicked
                    if (data.bv.getSubmitButton()) {
                        // Check if all fields in tab are valid

                        var isValidTab = data.bv.isValidContainer($tabPane);
                        $icon.addClass(isValidTab ? 'fa-check' : 'fa-times');

                    }
                    data.bv.disableSubmitButtons(false);
                });

            $.ajax({
                url: 'MyProfile.aspx/GetCity',
                type: 'POST',
                dataType: 'json',
                async: false,
                contentType: 'application/json; charset=utf-8',
                success: function (data) {
                    if (data.d == "") {
                        event.preventDefault();
                        return false;
                    }
                    else {
                        var CityData = data.d[0];

                        availableCity = [];

                        for (var i = 0; i < CityData.length; i++) {
                            availableCity.push(CityData[i]);
                        }

                        $(".txtPrimCity").autocomplete({
                            source: availableCity,
                            minLength: 0,
                            scroll: true
                        });

                        $(".txtPrimCity").on('blur', function () {
                            StateCountryData('P', $(".txtPrimCity").val());
                        });

                        $(".txtPrimCity").on('autocompleteselect', function (e, ui) {
                            StateCountryData('P', ui.item.value);
                        });

                        $(".txtSecCity").autocomplete({
                            source: availableCity,
                            minLength: 0,
                            scroll: true
                        });

                        $(".txtSecCity").on('autocompleteselect', function (e, ui) {
                            StateCountryData('S', ui.item.value);
                        });

                        $(".txtSecCity").on('blur', function () {
                            StateCountryData('S', $(".txtSecCity").val());
                        });

                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    ModelMsg('Something is wrong...', 3);
                }
            });

            $('#tabs a').click(function (e) {
                e.preventDefault();
                $(this).tab('show');
            });
        });

        function _btnCheck() {

            var IsValid = true;

            if (!$('.chkPanApplicable').find('input').is(':checked')) {
                if ($('.txtPanNo').val() == '') {
                    ModelMsg("Please enter PAN NO.", 3);
                    IsValid = false;
                }
                else if ($(".flCPanNoUpload").val() == '' && $(".hdnPANFile").val() == '') {
                    ModelMsg("Please select PAN NO image.", 3);
                    IsValid = false;
                }
            }
            if (IsValid && $('.txtGSTIN').val() != '' && $('.txtPanNo').val() == '') {
                ModelMsg("Please Enter PAN no.", 3);
                IsValid = false;
            }
            if (IsValid && !$('.chkCompositeScheme').find('input').is(':checked')) {
                if ($('.txtGSTIN').val() == '') {
                    ModelMsg("Please enter GSTIN No.", 3);
                    IsValid = false;
                }
                else if ($(".flcGSTINUpload").val() == '' && $(".hdnGSTFile").val() == '') {
                    ModelMsg("Please select GSTIN image.", 3);
                    IsValid = false;
                }
            }
            if (IsValid && $('.rdoIsRegComposite').find(":checked").val() == "1") {

                if ($(".flcVATRegNoUpload").val() == '' && $(".hdnVATFile").val() == '') {
                    ModelMsg("Please Download and Upload Declaration form for registered under Composite Scheme image.", 3);
                    IsValid = false;
                }
            }
            if (IsValid && $('.txtCSTRegNo').val() != "") {

                if ($(".flcCSTRegNoUpload").val() == '' && $(".hdnCSTFile").val() == '') {
                    ModelMsg("Please select CST REGISTRATION image.", 3);
                    IsValid = false;
                }
            }
            if (IsValid) {
                if (parseInt($('.hdnPrimCity').val()) > 0) {
                    //
                }
                else {
                    ModelMsg("Please Enter Address and City in Address Tab.", 3);
                    $(this).tab('show');
                    $('#tabs a[href="#tabs-2"]').tab('show');
                    $('.accountForm').bootstrapValidator('validate');
                    IsValid = false;
                }
            }

            if (IsValid && $('.txtSecAddress1').val() != "") {
                if (parseInt($('.hdnSecCity').val()) > 0) {
                    //
                }
                else {
                    ModelMsg("Please Enter City in Secondary Address Tab.", 3);
                    $(this).tab('show');
                    $('#tabs a[href="#tabs-2"]').tab('show');
                    $('.accountForm').bootstrapValidator('validate');
                    IsValid = false;
                }
            }

            if (IsValid) {
                if (!$('.accountForm').data('bootstrapValidator').isValid())
                    $('.accountForm').bootstrapValidator('validate');

                IsValid = $('.accountForm').data('bootstrapValidator').isValid();
            }
            if (IsValid) {
                $.blockUI({
                    message: '<img src="../Images/loadingbd.gif" />',
                    css: {
                        padding: 0,
                        margin: 0,
                        width: '15%',
                        top: '36%',
                        left: '40%',
                        textAlign: 'center',
                        cursor: 'wait'
                    }
                });
            }

            return IsValid;
        }

        function StateCountryData(Type, City) {

            if (City != "") {
                if (City.split("-").length > 0) {

                    var CityID = City.split("-")[0];

                    $.ajax({
                        url: 'MyProfile.aspx/StateCountryData',
                        type: 'POST',
                        contentType: "application/json; charset=utf-8",
                        data: "{'City':'" + CityID + "'}",
                        dataType: "json",
                        success: function (data) {

                            if (data.d[0] != null) {

                                if (Type == 'P') {
                                    $('.hdnPrimCity').val(data.d[0].CityID);
                                    $('.hdnPrimState').val(data.d[0].StateID);
                                    $('.hdnPrimCountry').val(data.d[0].CountryID);
                                    $('.txtPrimState').val(data.d[0].StateName);
                                    $('.txtPrimCountry').val(data.d[0].CountryName);
                                }
                                else {
                                    $('.hdnSecCity').val(data.d[0].CityID);
                                    $('.hdnSecState').val(data.d[0].StateID);
                                    $('.hdnSecCountry').val(data.d[0].CountryID);
                                    $('.txtSecState').val(data.d[0].StateName);
                                    $('.txtSecCountry').val(data.d[0].CountryName);
                                }
                            }
                            else {
                                ModelMsg('Selected City is not found...', 3);

                                if (Type == 'P') {
                                    $('.txtPrimCity').val("");
                                    $('.txtPrimState').val("");
                                    $('.txtPrimCountry').val("");
                                    $('.hdnPrimState').val(0);
                                    $('.hdnPrimCountry').val(0);
                                    $('.hdnPrimCity').val(0);
                                }
                                else {
                                    $('.txtSecCity').val("");
                                    $('.txtSecState').val("");
                                    $('.txtSecCountry').val("");
                                    $('.hdnSecState').val(0);
                                    $('.hdnSecCountry').val(0);
                                    $('.hdnSecCity').val(0);
                                }

                                return;
                            }
                        },
                        error: function (XMLHttpRequest, textStatus, errorThrown) {
                            ModelMsg('Something is wrong...', 3);
                        }
                    });
                }
                else {
                    ModelMsg('Select Proper City', 3);

                    if (Type == 'P') {
                        $('.txtPrimCity').val("");
                        $('.txtPrimState').val("");
                        $('.txtPrimCountry').val("");
                        $('.hdnPrimState').val(0);
                        $('.hdnPrimCountry').val(0);
                        $('.hdnPrimCity').val(0);
                    }
                    else {
                        $('.txtSecCity').val("");
                        $('.txtSecState').val("");
                        $('.txtSecCountry').val("");
                        $('.hdnSecState').val(0);
                        $('.hdnSecCountry').val(0);
                        $('.hdnSecCity').val(0);
                    }

                    return;
                }
            }
        }

        function downloadfn() {
            window.open("../Document/CSV Formats/CompositionScheme_Declareation_Form.pdf");
        }

        function ViewPhoto(ctrl, id, hdnID, txt, lbl) {

            var oFReader = new FileReader();
            var pathFile = $('.' + id)[0].files[0];
            if (pathFile != null && pathFile != "" && pathFile != "undefined") {
                oFReader.readAsDataURL(pathFile);
                oFReader.onload = function (e) {

                    $.colorbox({
                        width: '80%',
                        height: '80%',
                        iframe: true,
                        href: e.target.result,
                        title: '<b>' + $('.' + lbl).text() + '</b> : ' + $('.' + txt).val()
                    });
                }
            }
            else if ($('.' + hdnID).val() != "") {
                $.colorbox({
                    width: '80%',
                    height: '80%',
                    iframe: true,
                    href: $('.' + hdnID).val(),
                    title: '<b>' + $('.' + lbl).text() + '</b> : ' + $('.' + txt).val()
                });
            }
            else {
                ModelMsg("Please Select File", 3);
            }
        }

        function PanApplicable(chk) {
            if (!$(chk).is(":checked")) {
                $('.txtPanNo').removeAttr('disabled');
                $('.flCPanNoUpload').removeAttr('disabled');
                $('.btnPanView').removeAttr('disabled');

            }
            else {
                $('.txtPanNo').val('');
                $('.txtPanNo').attr('disabled', 'disabled');
                $('.flCPanNoUpload').attr('disabled', 'disabled');
                $('.btnPanView').attr('disabled', 'disabled');
            }
        }

        function CompositeScheme(chk) {

            if (!$(chk).is(":checked")) {
                $('.txtGSTIN').removeAttr('disabled');
                $('.flcGSTINUpload').removeAttr('disabled');
                $('.btnGSTView').removeAttr('disabled');
            } else {
                $('.txtGSTIN').val('');
                $('.txtGSTIN').attr('disabled', 'disabled');
                $('.flcGSTINUpload').attr('disabled', 'disabled');
                $('.btnGSTView').attr('disabled', 'disabled');
            }

        }

        function fnValidatePAN(txt) {

            var panno = $(txt).val();

            if (panno != "") {

                var panPat = /^([a-zA-Z]{5})(\d{4})([a-zA-Z]{1})$/;

                var code = /([C,P,H,F,A,T,B,L,J,G])/;

                var code_chk = panno.substring(3, 4);

                if (panno.search(panPat) == -1) {
                    ModelMsg("Invaild PAN Card No.", 3);
                    $(txt).val("");
                    return false;
                }
                if (code.test(code_chk) == false) {
                    ModelMsg("Invaild PAN Card No.", 3);
                    $(txt).val("");
                    return false;
                }
                $('.chkPanApplicable').find('input').attr('disabled', 'disabled');
            }
            else {
                $('.chkPanApplicable').find('input').removeAttr('disabled');
            }
        }

        function fnValidateGSTIN(txt) {

            var gstval = $(txt).val();
            if (gstval != "") {

                var panPat = /^[0-9]{2}[A-Za-z]{5}[0-9]{4}[A-Za-z]{1}[0-9a-zA-Z]{1}[a-zA-Z]{1}[0-9a-zA-Z]{1}$/;

                if (gstval.search(panPat) == -1) {
                    ModelMsg("Invalid GSTIN No", 3);
                    $(txt).val("");
                    return false;
                }

                $('.chkCompositeScheme').find('input').attr('disabled', 'disabled');
            }
            else {
                $('.chkCompositeScheme').find('input').removeAttr('disabled');
            }
        }

        function CheckFile(event) {


            var file = event.files[0];
            if (file.size >= 2 * 1024 * 1024) {
                alert("Image file size should be maximum 2MB.");
                $(event).val('');
                return;
            }
            var ext = file.name.replace(/^.*\./, '').toLowerCase();

            if (ext == "jpg" || ext == "png" || ext == "gif" || ext == "jpeg" || ext == "pdf") {

            }
            else {
                alert("You can upload only Pdf and Image File.");
                $(event).val('');
                return;
            }
        }


    </script>
    <style>
        .BlinkLable {
            font-weight: bold;
            color: red;
            font-size: 15px;
            animation: blinker 1s linear infinite;
            background-color: yellow;
        }

        @keyframes blinker {
            50% {
                opacity: 0.2;
                color: blue;
            }
        }
    </style>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel panel-default" style="margin-top: 45px; margin-left: 18px;">
        <div class="panel-body">
            <div class="accountForm">
                <div class="row">
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Label ID="lblCustCode" runat="server" Text="Customer Code" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtCustCode" runat="server" Enabled="false" CssClass="form-control" autocomplete="off"></asp:TextBox>
                        </div>
                    </div>
                    <div class="col-lg-8">
                        <div class="input-group form-group">
                            <asp:Label ID="lblCustName" runat="server" Text="Customer Name" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtCustName" runat="server" Enabled="false" CssClass="form-control"></asp:TextBox>
                        </div>
                    </div>
                </div>
                <div style="color: red; float: right;">
                    <span>You can upload only Pdf and Image File.</span></br>
                    <span>Image file size should be maximum 2MB</span>
                </div>
                <div style="height=100%">
                    <span class="BlinkLable">You can submit this form only one time. Please fill the form carefully. You can not update this form data again..!</span>
                </div>
                <ul id="tabs" class="nav nav-tabs" role="tablist">
                    <li class="active"><a href="#tabs-1" role="tab" data-toggle="tab">Statutory Details</a></li>
                    <li><a href="#tabs-2" role="tab" data-toggle="tab">Address of Principal Place of Business</a></li>
                </ul>
                <div id="myTabContent" class="tab-content">
                    <div id="tabs-1" class="tab-pane active">
                        <div class="row">
                            <div class="col-lg-4">
                                <div class="input-group form-group">
                                    <asp:Label ID="lblPanNo" runat="server" Text="*PAN NO." Style="width: 50%;" CssClass="lblPanNo input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtPanNo" runat="server" TabIndex="1" CssClass="txtPanNo form-control" onblur="fnValidatePAN(this);" MaxLength="10"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblGSTIN" runat="server" Text="*GSTIN/ PROVISIONAL ID" Style="width: 50%;" CssClass="lblGSTIN input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtGSTIN" runat="server" TabIndex="4" CssClass="txtGSTIN form-control" onblur="fnValidateGSTIN(this);" MaxLength="15"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblStateVATRegNo" runat="server" Text="ARE YOU REGISTERED UNDER COMPOSITE SCHEME ?" Style="width: 38%;" CssClass="lblStateVATRegNo input-group-addon"></asp:Label>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblCSTRegNo" runat="server" Text="CST/VAT REGISTRATION" Style="width: 50%;" CssClass="lblCSTRegNo input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtCSTRegNo" TabIndex="9" runat="server" CssClass="txtCSTRegNo form-control" MaxLength="25"></asp:TextBox>
                                </div>
                            </div>
                            <div class="col-lg-2">
                                <div class="input-group form-group">
                                    <asp:Label ID="lblNotApplicable" runat="server" Text="Not Applicable" CssClass="input-group-addon"></asp:Label>
                                    <asp:CheckBox ID="chkPanApplicable" TabIndex="2" runat="server" onclick="PanApplicable(this);" CssClass="chkPanApplicable form-control" />
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblCompositeScheme" runat="server" Text="Not Register" CssClass="input-group-addon"></asp:Label>
                                    <asp:CheckBox ID="chkCompositeScheme" TabIndex="5" runat="server" onclick="CompositeScheme(this);" CssClass="chkCompositeScheme form-control" />
                                </div>
                                <div class="input-group form-group">
                                    <asp:RadioButtonList runat="server" ID="rdoIsRegComposite" CssClass="rdoIsRegComposite" RepeatDirection="Horizontal">
                                        <asp:ListItem Text="Yes" Value="1" />
                                        <asp:ListItem Text="No" Value="0" Selected="True" />
                                    </asp:RadioButtonList>
                                </div>
                            </div>
                            <div class="col-lg-4">
                                <div class="input-group form-group">
                                    <asp:FileUpload ID="flCPanNoUpload" TabIndex="3" Style="width: 150%;" runat="server" CssClass="flCPanNoUpload form-control" accept=".png,.jpg,.jpeg,.gif,.pdf" onchange="CheckFile(this);" />
                                    <input type="hidden" runat="server" id="hdnPANFile" class="hdnPANFile" />
                                </div>
                                <div class="input-group form-group">
                                    <asp:FileUpload ID="flcGSTINUpload" TabIndex="6" Style="width: 150%;" runat="server" CssClass="flcGSTINUpload form-control" accept=".png,.jpg,.jpeg,.gif,.pdf" onchange="CheckFile(this);" />
                                    <input type="hidden" runat="server" id="hdnGSTFile" class="hdnGSTFile" />
                                </div>
                                <div class="input-group form-group">
                                    <asp:FileUpload ID="flcVATRegNoUpload" TabIndex="8" Style="width: 150%;" runat="server" CssClass="flcVATRegNoUpload form-control" accept=".png,.jpg,.jpeg,.gif,.pdf" onchange="CheckFile(this);" />
                                    <input type="hidden" runat="server" id="hdnVATFile" class="hdnVATFile" />
                                </div>
                                <div class="input-group form-group">
                                    <asp:FileUpload ID="flcCSTRegNoUpload" TabIndex="10" Style="width: 150%;" runat="server" CssClass="flcCSTRegNoUpload form-control" accept=".png,.jpg,.jpeg,.gif,.pdf" onchange="CheckFile(this);" />
                                    <input type="hidden" runat="server" id="hdnCSTFile" class="hdnCSTFile" />
                                </div>
                            </div>
                            <div class="col-lg-2">
                                <div class="input-group form-group">
                                    <asp:LinkButton ID="btnPanView" runat="server" Text="View" OnClientClick="ViewPhoto(this,'flCPanNoUpload','hdnPANFile','txtPanNo','lblPanNo'); return false;" CssClass="btnPanView btn btn-default" />
                                </div>
                                <div class="input-group form-group">
                                    <asp:LinkButton ID="btnGSTView" runat="server" Text="View" OnClientClick="ViewPhoto(this,'flcGSTINUpload','hdnGSTFile','txtGSTIN','lblGSTIN'); return false;" CssClass="btnGSTView btn btn-default" />
                                </div>
                                <div class="input-group form-group">
                                    <asp:LinkButton ID="btnVATView" runat="server" Text="View" OnClientClick="ViewPhoto(this,'flcVATRegNoUpload','hdnVATFile','txtGSTIN','lblStateVATRegNo'); return false;" CssClass="btn btn-default" />
                                    <asp:LinkButton ID="btnDeclarationDownload" runat="server" Text="Download" OnClientClick="downloadfn(); return false;" Style="margin-left: 10px; display: none;" CssClass="btn btn-default" />
                                </div>
                                <div class="input-group form-group">
                                    <asp:LinkButton ID="btnCSTView" runat="server" Text="View" OnClientClick="ViewPhoto(this,'flcCSTRegNoUpload','hdnCSTFile','txtCSTRegNo','lblCSTRegNo'); return false;" CssClass="btn btn-default" />
                                </div>
                            </div>
                        </div>
                    </div>
                    <div id="tabs-2" class="tab-pane">
                        <div class="row">
                            <div class="col-lg-6" style="height: 380px; overflow-y: scroll;">
                                <asp:Label ID="lblPrimAddress" runat="server" Text="*Primary Address" Style="text-align: center;" ForeColor="Maroon" Font-Bold="true" CssClass="input-group-addon"></asp:Label>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblPrimAddress1" runat="server" Text="*Address 1" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtPrimAddress1" TabIndex="1" runat="server" CssClass="form-control" MaxLength="100" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblPrimAddress2" runat="server" Text="Address 2" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtPrimAddress2" TabIndex="2" runat="server" CssClass="form-control" MaxLength="100"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblPrimLandMark" runat="server" Text="Landmark " CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtPrimLandMark" TabIndex="3" runat="server" CssClass="form-control" MaxLength="150"></asp:TextBox>
                                </div>
                                <div class="input-group form-group" id="divCity" runat="server">
                                    <asp:Label ID="lblCity" runat="server" Text='*City' CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtPrimCity" TabIndex="4" CssClass="txtPrimCity form-control" MaxLength="100" runat="server" Style="background-color: rgb(250, 255, 189);" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                                    <input type="hidden" id="hdnPrimCity" class="hdnPrimCity" runat="server" value="0" />
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblPrimDistrict" runat="server" Text="*District" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtPrimDistrict" TabIndex="5" runat="server" CssClass="form-control" MaxLength="150" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblPrimSate" runat="server" Text="*State" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtPrimState" runat="server" TabIndex="6" CssClass="txtPrimState form-control" Enabled="false"></asp:TextBox>
                                    <input type="hidden" id="hdnPrimState" class="hdnPrimState" runat="server" value="0" />
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblPrimCountry" runat="server" Text="*Country" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtPrimCountry" runat="server" TabIndex="7" CssClass="txtPrimCountry form-control" Enabled="false"></asp:TextBox>
                                    <input type="hidden" id="hdnPrimCountry" class="hdnPrimCountry" runat="server" value="0" />
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblPrimPinCode" runat="server" Text="*Pin Code" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtPrimPinCode" runat="server" TabIndex="8" CssClass="txtPrimPinCode form-control" MaxLength="6"
                                        data-bv-stringlength="true" data-bv-stringlength-max="6" data-bv-stringlength-min="6" onkeypress="return isNumberKey(event);" onpaste="return false;" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblPrimOfficeEmail" runat="server" Text="*OFFICE E-MAIL ADDRESS" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtPrimOfficeEmail" runat="server" TabIndex="9" CssClass="form-control" MaxLength="250" data-bv-emailaddress="true" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblPrimOfficePhoneNo" runat="server" Text="*OFFICE TELEPHONE NO." CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtPrimOfficePhoneNo" runat="server" TabIndex="10" MaxLength="10" onkeypress="return isNumberKey(event);"
                                        data-bv-stringlength="true" data-bv-stringlength-max="10" data-bv-stringlength-min="10" CssClass="form-control" onpaste="return false;" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblPrimContactPerson" runat="server" Text="*Contact Person" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtPrimContactPerson" runat="server" TabIndex="11" CssClass="form-control" MaxLength="150" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblPrimMobileNo" runat="server" Text="*MOBILE NO." CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtPrimMobileNo" runat="server" TabIndex="12" MaxLength="10" onkeypress="return isNumberKey(event);" CssClass="form-control"
                                        data-bv-stringlength="true" data-bv-stringlength-max="10" data-bv-stringlength-min="10"
                                        onpaste="return false;" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblPrimEmail" runat="server" Text="*Email ID" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtPrimEmail" runat="server" TabIndex="13" CssClass="form-control" MaxLength="250" data-bv-notempty="true" data-bv-emailaddress="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblPrimWebSite" runat="server" Text="WEB" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtPrimWebSite" TabIndex="14" runat="server" CssClass="form-control" data-bv-uri="true" MaxLength="250"></asp:TextBox>
                                </div>
                                <div style="color: red; float: left;">
                                    <span>Please write "http://" or "https://" before website name.</span>
                                </div>
                            </div>
                            <div class="col-lg-6" style="height: 380px; overflow-y: scroll">
                                <asp:Label ID="lblSecAddress" runat="server" Text="Secondary Address" Style="text-align: center;" ForeColor="Maroon" Font-Bold="true" CssClass="input-group-addon"></asp:Label>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblSecAddress1" runat="server" Text="Address 1" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtSecAddress1" runat="server" TabIndex="15" CssClass="txtSecAddress1 form-control" MaxLength="100"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblSecAddress2" runat="server" Text="Address 2" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtSecAddress2" runat="server" TabIndex="16" CssClass="form-control" MaxLength="100"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblSecLandMark" runat="server" Text="Landmark " CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtSecLandMark" runat="server" TabIndex="17" CssClass="form-control" MaxLength="150"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblSecCity" runat="server" Text='City' CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtSecCity" CssClass="txtSecCity form-control" TabIndex="18" runat="server" MaxLength="100" Style="background-color: rgb(250, 255, 189);"></asp:TextBox>
                                    <input type="hidden" id="hdnSecCity" class="hdnSecCity" runat="server" value="0" />
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblSecDistrict" runat="server" Text="District" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtSecDistrict" runat="server" TabIndex="19" CssClass="form-control" MaxLength="100"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblSecState" runat="server" Text="State" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtSecState" runat="server" TabIndex="20" CssClass="txtSecState form-control" Enabled="false"></asp:TextBox>
                                    <input type="hidden" id="hdnSecState" class="hdnSecState" runat="server" value="0" />
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblSecCountry" runat="server" Text="Country" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtSecCountry" runat="server" TabIndex="21" CssClass="txtSecCountry form-control" Enabled="false"></asp:TextBox>
                                    <input type="hidden" id="hdnSecCountry" class="hdnSecCountry" runat="server" value="0" />
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblSecPinCode" runat="server" Text="Pin Code" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtSecPinCode" runat="server" TabIndex="22" onkeypress="return isNumberKey(event);" MaxLength="6" onpaste="return false;"
                                        data-bv-stringlength="true" data-bv-stringlength-max="6" data-bv-stringlength-min="6" CssClass="form-control"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblSecOfficeEmail" runat="server" Text="OFFICE E-MAIL ADDRESS" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtSecOfficeEmail" TabIndex="23" runat="server" CssClass="form-control" data-bv-emailaddress="true" MaxLength="250"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblSecOfficePhoneNo" runat="server" Text="OFFICE TELEPHONE NO." CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtSecOfficePhoneNo" TabIndex="24" runat="server" data-bv-stringlength="true"
                                        data-bv-stringlength-max="10" data-bv-stringlength-min="10" MaxLength="10" onkeypress="return isNumberKey(event);" CssClass="form-control" onpaste="return false;"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblSecContactPerson" runat="server" Text="Contact Person" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtSecContactPerson" TabIndex="25" runat="server" CssClass="form-control" MaxLength="150"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblSecMobileNo" runat="server" Text="MOBILE NO." CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtSecMobileNo" runat="server" TabIndex="26" MaxLength="10" data-bv-stringlength="true"
                                        data-bv-stringlength-max="10" data-bv-stringlength-min="10" onkeypress="return isNumberKey(event);" CssClass="form-control" onpaste="return false;"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblSecEmail" runat="server" Text="Email ID" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtSecEmail" runat="server" TabIndex="27" CssClass="form-control" data-bv-emailaddress="true" MaxLength="250"></asp:TextBox>
                                </div>
                                <div class="input-group form-group">
                                    <asp:Label ID="lblSecWebSite" runat="server" Text="WEB" CssClass="input-group-addon"></asp:Label>
                                    <asp:TextBox ID="txtSecWebSite" runat="server" TabIndex="28" CssClass="form-control" data-bv-uri="true" MaxLength="250"></asp:TextBox>
                                </div>
                                <div style="color: red; float: left;">
                                    <span>Please write "http://" or "https://" before website name.</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <asp:Button ID="btnSubmit" runat="server" Text="Submit" OnClientClick="return _btnCheck();" TabIndex="28" OnClick="btnSubmit_Click" CssClass="btn btn-default" />
                <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-default" OnClick="btnCancel_Click" TabIndex="29" UseSubmitBehavior="false" CausesValidation="false" />
            </div>
        </div>
    </div>
</asp:Content>

