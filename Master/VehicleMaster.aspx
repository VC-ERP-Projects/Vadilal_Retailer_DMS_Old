<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="VehicleMaster.aspx.cs" Inherits="Master_VehicleMaster" %>


<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <style>
        .error {
            /*border-color: red;*/
            box-shadow: 0px 0px 0px 2px #F55575;
            /*box-shadow: 0 0 3px rgba(245,85,117,.9);*/
            /*border:2px solid red;*/
        }

            .error:focus {
                /*border-color: red;*/
                box-shadow: 0px 0px 0px 2px #F55575;
                /*box-shadow: 0 0 3px rgba(245,85,117,.9);*/
            }
    </style>
    <script type="text/javascript">

        $(function () {
            Relaod();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            Relaod();
        }

        function Relaod() {

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
            $('.accountForm').data('bootstrapValidator').disableSubmitButtons(false);

        }

        function VehicleActiveCheck() {
            if ($(".txtSalesDate").val() == "") {
                //document.getElementById('<%= chkActive.ClientID %>').checked = true;
                $('#<% = chkActive.ClientID %>').prop('checked', true);
            }

            else {
                //document.getElementById('<%= chkActive.ClientID %>').checked = false;
                $('#<% = chkActive.ClientID %>').prop('checked', false);
            }

        }

        function _btnCheck() {
            if (!$('.accountForm').data('bootstrapValidator').isValid())
                $('.accountForm').bootstrapValidator('validate');

            IsValid = $('.accountForm').data('bootstrapValidator').isValid();

            if ($('#<% = txtVehicleNumber.ClientID %>').val() == "") {
                if (IsValid)
                    $('#<% = txtVehicleNumber.ClientID %>').focus();
                IsValid = false;
                $('#<% = txtVehicleNumber.ClientID %>').addClass('error');
                $('#<% = txtVehicleNumber.ClientID %>').attr("PlaceHolder", "Required Field");
            } else {
                if (IsValid == true)
                    IsValid = true;
                $('#<% = txtVehicleNumber.ClientID %>').removeClass('error');
            }

            <%--if ($('#<% = ddlVehicleType.ClientID %>').val() == "0") {
                if (IsValid)
                    $('#<% = ddlVehicleType.ClientID %>').focus();
                IsValid = false;
                $('#<% = ddlVehicleType.ClientID %>').addClass('error');
                $('#<% = ddlVehicleType.ClientID %>').attr("Title", "Required Field");
            } else {
                if (IsValid == true)
                    IsValid = true;
                $('#<% = ddlVehicleType.ClientID %>').removeClass('error');
            }
            if ($('#<% = ddlWheelType.ClientID %>').val() == "0") {
                if (IsValid)
                    $('#<% = ddlWheelType.ClientID %>').focus();
                IsValid = false;
                $('#<% = ddlWheelType.ClientID %>').addClass('error');
                $('#<% = ddlWheelType.ClientID %>').attr("Title", "Required Field");
            } else {
                if (IsValid == true)
                    IsValid = true;
                $('#<% = ddlWheelType.ClientID %>').removeClass('error');
            }
            if ($('#<% = ddlFuelType.ClientID %>').val() == "0") {
                if (IsValid)
                    $('#<% = ddlFuelType.ClientID %>').focus();
                IsValid = false;
                $('#<% = ddlFuelType.ClientID %>').addClass('error');
                $('#<% = ddlFuelType.ClientID %>').attr("Title", "Required Field");
            } else {
                if (IsValid == true)
                    IsValid = true;
                $('#<% = ddlFuelType.ClientID %>').removeClass('error');
            }--%>
          <%--  if ($('#<% = txtAverage.ClientID %>').val() == "") {
                if (IsValid)
                    $('#<% = txtAverage.ClientID %>').focus();
                IsValid = false;
                $('#<% = txtAverage.ClientID %>').addClass('error');
                $('#<% = txtAverage.ClientID %>').attr("PlaceHolder", "Required Field");
            } else {
                if (IsValid == true)
                    IsValid = true;
                $('#<% = txtAverage.ClientID %>').removeClass('error');
            }
            if ($('#<% = txtLength.ClientID %>').val() == "") {
                if (IsValid)
                    $('#<% = txtLength.ClientID %>').focus();
                IsValid = false;
                $('#<% = txtLength.ClientID %>').addClass('error');
                $('#<% = txtLength.ClientID %>').attr("PlaceHolder", "Required Field");
            } else {
                if (IsValid == true)
                    IsValid = true;
                $('#<% = txtLength.ClientID %>').removeClass('error');
            }
            if ($('#<% = txtDateOfPaint.ClientID %>').val() == "") {
                if (IsValid)
                    $('#<% = txtDateOfPaint.ClientID %>').focus();
                IsValid = false;
                $('#<% = txtDateOfPaint.ClientID %>').addClass('error');
                $('#<% = txtDateOfPaint.ClientID %>').attr("PlaceHolder", "Required Field");
            } else {
                if (IsValid == true)
                    IsValid = true;
                $('#<% = txtDateOfPaint.ClientID %>').removeClass('error');
            }
            if ($('#<% = txtYearOfModel.ClientID %>').val() == "") {
                if (IsValid)
                    $('#<% = txtYearOfModel.ClientID %>').focus();
                IsValid = false;
                $('#<% = txtYearOfModel.ClientID %>').addClass('error');
                $('#<% = txtYearOfModel.ClientID %>').attr("PlaceHolder", "Required Field");
            } else {
                if (IsValid == true)
                    IsValid = true;
                $('#<% = txtYearOfModel.ClientID %>').removeClass('error');
            }--%>
            return IsValid;
        }


    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">

    <div style="margin-left: 15px">
        <input type="checkbox" name="onoffswitch" class="_auchk" style="margin-bottom: 10px" onchange="javascript: setTimeout('__doPostBack(\'\',\'\')', 0)" data-size="large" data-on-text="Add" data-off-text="Update" clientidmode="Static" id="chkMode" runat="server" checked="checked" onserverchange="chkMode_Checked" />
    </div>
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="accountForm">
                <div class="row">
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <center>
                                <a class="imgVehicle" href="../Images/no.jpg" id="alink" runat="server">
                                    <asp:Image ID="imgVehicle" CssClass="imgVehicle" ImageUrl="~/Images/no.jpg" runat="server" Style="width: 30%;" /></a>
                                <asp:AsyncFileUpload UploaderStyle="Traditional" ID="afuVehiclePhoto" ClientIDMode="AutoID" runat="server"
                                    OnUploadedComplete="afuVehiclePhoto_UploadedComplete" Style="margin-left: 29%; margin-top: 3%" CompleteBackColor="White" CssClass="imageUploaderField" />
                            </center>
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Label runat="server" Text="Vehicle ID" ID="lblVID" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox runat="server" ID="txtVID" PlaceHolder="Vehicle ID" CssClass="form-control" AutoPostBack="True" OnTextChanged="txtVehicleNumber_TextChanged" Style="margin-right: -3%" />
                            <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtVehicle" runat="server" ServicePath="../WebService.asmx"
                                UseContextKey="true" ServiceMethod="GetVehicle" MinimumPrefixLength="1" CompletionInterval="10"
                                EnableCaching="false" CompletionSetCount="1" TargetControlID="txtVID">
                            </asp:AutoCompleteExtender>
                        </div>
                        <div class="input-group form-group">
                            <asp:Label runat="server" Text="Vehicle No" ID="lblVehicleNo" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox ID="txtVehicleNumber" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>

                    </div>
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Label ID="lblIsActive" runat="server" Text="Is Active" CssClass="input-group-addon"></asp:Label>
                            <asp:CheckBox ID="chkActive" runat="server" Checked="true" CssClass="chkActive form-control" />
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Label Text="Vehicle Type" ID="lblVehicleType" runat="server" CssClass="input-group-addon" />
                            <asp:DropDownList runat="server" ID="ddlVehicleType" CssClass="form-control">
                                <asp:ListItem Text="--Select--" Value="0" />
                                <asp:ListItem Text="MiniTruck" Value="M" />
                                <asp:ListItem Text="Rickshow" Value="R" />
                                <asp:ListItem Text="HeavyTruck" Value="H" />
                            </asp:DropDownList>
                        </div>
                        <div class="input-group form-group">
                            <asp:Label Text="Wheel Type" ID="Label1" runat="server" CssClass="input-group-addon" />
                            <asp:DropDownList runat="server" ID="ddlWheelType" CssClass="form-control">
                                <asp:ListItem Text="--Select--" Value="0" />
                                <asp:ListItem Text="3 Wheeler" Value="3" />
                                <asp:ListItem Text="4 Wheeler" Value="4" />
                                <asp:ListItem Text="6 Wheeler & Above" Value="6" />
                            </asp:DropDownList>
                        </div>
                        <div class="input-group form-group">
                            <asp:Label Text="Fuel Type" ID="lblFuelType" runat="server" CssClass="input-group-addon" />
                            <asp:DropDownList runat="server" ID="ddlFuelType" CssClass="form-control">
                                <asp:ListItem Text="--Select--" Value="0" />
                                <asp:ListItem Text="Petrol" Value="P" />
                                <asp:ListItem Text="Diesel" Value="D" />
                                <asp:ListItem Text="CNG" Value="C" />
                                <asp:ListItem Text="LPG" Value="L" />
                            </asp:DropDownList>
                        </div>
                        <div class="input-group form-group">
                            <asp:Label Text="Average" ID="lblAverage" runat="server" CssClass="input-group-addon" />
                            <asp:TextBox runat="server" ID="txtAverage" CssClass="form-control" placeholder="Kms." MaxLength="8" onkeypress="return isNumberKey(event);" onpaste="return false;" />
                        </div>

                    </div>
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Label Text="ModelName" ID="lblModelName" runat="server" CssClass="input-group-addon" />
                            <asp:TextBox runat="server" ID="txtModelName" placeholder="Model Name" CssClass="form-control" />
                        </div>
                        <div class="input-group form-group">
                            <asp:Label Text="Manufacturer" ID="lblmfg" runat="server" CssClass="input-group-addon" />
                            <asp:TextBox runat="server" ID="txtManufacturer" placeholder="Manufacturer" CssClass="form-control" />
                        </div>
                        <div class="input-group form-group">
                            <asp:Label Text="Size (Sq. Feet)" ID="lblSize" runat="server" CssClass="input-group-addon" />
                            <table>
                                <tr>
                                    <td width="85%">
                                        <asp:TextBox runat="server" ID="txtLength" placeholder="Square Feet" MaxLength="8" CssClass="form-control" onkeypress="return isNumberKey(event);" onpaste="return false;" />
                                    </td>
                                    <td width="15%">&nbsp; <a href="../Images/volume_box.gif" class="imgLBH" style="margin-left: 0%; vertical-align: bottom; width: auto">
                                        <img style="border: 1px solid #D76900; border-radius: 6px;" src="../Images/help.png" /></a>
                                    </td>
                                </tr>
                            </table>
                        </div>
                        <div id="divFSSI" runat="server" class="input-group form-group">
                            <asp:Label Text="FSSAI No. / End Date" ID="lblFSSINo" runat="server" CssClass="input-group-addon" />
                            <asp:TextBox runat="server" ID="txtFSSINo" CssClass="form-control" />
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="input-group form-group">
                            <asp:Label Text="Year Of Model" ID="lblModel" runat="server" CssClass="input-group-addon" />
                            <asp:TextBox runat="server" ID="txtYearOfModel" placeholder="Year" MaxLength="4" CssClass="form-control" onkeypress="return isNumberKey(event);" onpaste="return false;" />
                        </div>
                        <div class="input-group form-group">
                            <asp:Label Text="Date of Paint" ID="lblPaint" runat="server" CssClass="input-group-addon" />
                            <asp:TextBox runat="server" ID="txtDateOfPaint" placeholder="Date Of Paint" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="datepick form-control" />
                        </div>
                        <div class="input-group form-group">
                            <asp:Label Text="Purchase Date" ID="lblPurDate" runat="server" CssClass="input-group-addon" />
                            <asp:TextBox ID="txtPurDate" runat="server" placeholder="Purchase Date" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="datepick form-control"></asp:TextBox>
                        </div>
                        <div class="input-group form-group">
                            <asp:Label Text="Sales Date" ID="lblSaleDate" runat="server" CssClass="input-group-addon" />
                            <asp:TextBox ID="txtSalesDate" runat="server" placeholder="Sales Date" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="datepick form-control txtSalesDate" onblur="VehicleActiveCheck();"></asp:TextBox>
                        </div>
                    </div>
                    <div class="col-lg-12">
                        <div class="input-group form-group">
                            <asp:Label ID="lblNotes" runat="server" Text="Notes" CssClass="input-group-addon"></asp:Label>
                            <asp:TextBox runat="server" ID="txtNotes" CssClass="form-control" TextMode="MultiLine" />
                        </div>
                    </div>

                </div>

                <div class="row">
                    <fieldset style="width: 99.5%;">
                        <legend>&nbsp; Attachment</legend>

                        <div class="col-lg-6">
                            <div class="input-group form-group">
                                <asp:Label Text="Attachment Name" ID="lblAttachment" runat="server" CssClass="input-group-addon" />
                                <asp:TextBox ID="txtAttachment" runat="server" CssClass="form-control"></asp:TextBox>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label Text="File Upload" ID="lblUpload" runat="server" CssClass="input-group-addon" />
                                <asp:AsyncFileUpload UploaderStyle="Traditional" ID="afuVehicle" ClientIDMode="AutoID" runat="server"
                                    OnUploadedComplete="afuVehicle_UploadedComplete" CssClass="file_uploader imageUploaderField form-control" CompleteBackColor="White" />
                            </div>
                        </div>
                        <div class="col-lg-6">
                            <div class="input-group form-group">
                                <asp:Label Text="Reminder Date" ID="lblAtchReminderDate" runat="server" CssClass="input-group-addon" />
                                <asp:TextBox ID="txtAtchReminderDate" runat="server" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="datepick form-control"></asp:TextBox>
                            </div>
                            <div class="input-group form-group">
                                <asp:Label Text="Notes" ID="lblAtchNotes" runat="server" CssClass="input-group-addon" />
                                <asp:TextBox ID="txtAtchNotes" runat="server" TextMode="MultiLine" CssClass="form-control"></asp:TextBox>
                            </div>
                        </div>

                        <div class="col-lg-10">
                        </div>
                        <div class="col-lg-1">
                            <asp:Button Text="Add Attachment" ID="btnImageUpload" Style="width: auto; min-width: 100px;" CssClass="form-control" runat="server" OnClick="btnImageUpload_Click" />
                        </div>

                        <div class="col-lg-12">
                            <br />
                            <asp:GridView runat="server" ID="gvAttach" AutoGenerateColumns="False" ClientIDMode="Static" EmptyDataText="No Attchment Found." OnRowCommand="gvAttach_RowCommand" CssClass="table" HeaderStyle-CssClass="table-header-gradient" Width="100%">
                                <Columns>
                                    <asp:TemplateField HeaderText="No.">
                                        <ItemTemplate>
                                            <asp:Label ID="lblNo" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Label>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Date">
                                        <ItemTemplate>
                                            <asp:Label ID="lblDate" runat="server" Text='<%# Bind("Date","{0:dd/MM/yyyy}") %>'></asp:Label>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Attachment">
                                        <ItemTemplate>
                                            <asp:Label ID="lblAttachment" runat="server" Text='<%# Bind("Attachment") %>'></asp:Label>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Notes">
                                        <ItemTemplate>
                                            <asp:Label ID="lblNotes" runat="server" Text='<%# Bind("Notes") %>'></asp:Label>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Reminder Date">
                                        <ItemTemplate>
                                            <asp:Label ID="lblReminderDate" runat="server" Text='<%# Bind("ReminderDate","{0:dd/MM/yyyy}") %>'></asp:Label>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Action">
                                        <ItemTemplate>
                                            <asp:LinkButton ID="lnkEdit" ToolTip="Edit" CommandName="EditMode" CommandArgument='<%# Container.DataItemIndex %>' runat="server" Width="10%"><img src="../Images/edit.png" alt="Edit"></img></asp:LinkButton>&nbsp&nbsp
                                        <asp:LinkButton ID="lnkDownload" ToolTip="Download" CommandName="Download" CommandArgument='<%# Container.DataItemIndex %>' runat="server" Width="10%"><img src="../Images/download.png" alt="Download"></img></asp:LinkButton>&nbsp&nbsp
                                        <asp:LinkButton ID="lnkDelete" ToolTip="Delete" runat="server" CommandName="DeleteMode" Width="10%" CommandArgument='<%# Container.DataItemIndex %>'
                                            OnClientClick="return confirm('Are sure you want delete this attchment?');"><img src="../Images/delete.png" alt="Delete"></img></asp:LinkButton>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </fieldset>
                </div>

                <asp:Button ID="btnSubmit" runat="server" Text="Submit" OnClientClick="return _btnCheck();" OnClick="btnSubmit_Click" CssClass="btn btn-default" />
                <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-default" OnClick="btnCancel_Click" UseSubmitBehavior="false" CausesValidation="false" />
            </div>
        </div>
</asp:Content>


