<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="QuestionMaster.aspx.cs" Inherits="Master_QuestionMaster" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">

        $(function () {
            _ChangeSelection($('.ddlCategory'));
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);

            $(".allownumericwithdecimal").keydown(function (e) {
                // Allow: backspace, delete, tab, escape, enter
                if ($.inArray(e.keyCode, [46, 8, 9, 27, 13, 110, 190, 86, 67]) !== -1 ||
                    // Allow: Ctrl+A, Command+A
                    ((e.keyCode == 65 || e.keyCode == 86 || e.keyCode == 67) && (e.ctrlKey === true || e.metaKey === true)) ||
                    // Allow: home, end, left, right, down, up
                    (e.keyCode >= 35 && e.keyCode <= 40)) {
                    // let it happen, don't do anything

                    var myval = $(this).val();
                    if (myval != "") {
                        if (isNaN(myval)) {
                            $(this).val('');
                            e.preventDefault();
                            return false;
                        }
                    }
                    return;
                }
                // Ensure that it is a number and stop the keypress
                if ((e.shiftKey || (e.keyCode < 48 || e.keyCode > 57)) && (e.keyCode < 96 || e.keyCode > 105)) {
                    e.preventDefault();
                }
            });
        });

        function EndRequestHandler2(sender, args) {
            _ChangeSelection($('.ddlCategory'));
        }

        function autoCompleteQues_OnClientPopulating(sender, args) {
            var key = $('.ddlType option:selected').text();
            sender.set_contextKey(key);
        }

        function _btnCheck() {
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');
            return $('._masterForm').data('bootstrapValidator').isValid();
        }

        function _ChangeSelection(ddl) {
            if ($(ddl).val() == 'S') {

                $('.ddlSelectivetype').show();
                $('.ddlDescriptivetype').hide();
                $('.ddlRatingType').hide();
            }
            else if ($(ddl).val() == 'D') {

                $('.ddlSelectivetype').hide();
                $('.ddlDescriptivetype').show();
                $('.ddlRatingType').hide();
            }
            else if ($(ddl).val() == 'R') {

                $('.ddlSelectivetype').hide();
                $('.ddlDescriptivetype').hide();
                $('.ddlRatingType').show();
            }
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div style="margin-left: 15px">
        <input type="checkbox" name="onoffswitch" class="_auchk" onchange="javascript: setTimeout('__doPostBack(\'\',\'\')', 0)" data-size="large" data-on-text="Add" data-off-text="Update" clientidmode="Static" id="chkMode" runat="server" checked="checked" onserverchange="chkMode_Checked" />
    </div>
    <div class="panel panel-default">
        <div class="panel-body _masterForm">
            <div class="row">
                <div class="col-lg-4">
                    <div class="input-group form-group" style="margin-bottom: 0px">
                        <asp:Label ID="lbltype" runat="server" Text="Type" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlType" runat="server" CssClass="ddlType form-control">
                            <asp:ListItem Text="Feedback" Value="F"></asp:ListItem>
                            <asp:ListItem Text="Competitor" Value="C"></asp:ListItem>
                            <asp:ListItem Text="Distributor Complaint" Value="DC"></asp:ListItem>
                             <asp:ListItem Text="Sales Staff Complaint" Value="SSC"></asp:ListItem>
                             <asp:ListItem Text="Product Complaint" Value="PC"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblNo" runat="server" Text="Code" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtQuesNo" runat="server" OnTextChanged="txtQuesNo_TextChanged" autocomplete="off" AutoPostBack="true" CssClass="form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="ACEtxtName" runat="server" ServiceMethod="GetQuestion" OnClientPopulating="autoCompleteQues_OnClientPopulating" 
                            ServicePath="../WebService.asmx" MinimumPrefixLength="1" CompletionInterval="10" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtQuesNo" UseContextKey="True" Enabled="false">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblActive" runat="server" Text="Is Active" CssClass="input-group-addon"></asp:Label>
                        <asp:CheckBox ID="ChkActive" runat="server" Checked="true" CssClass="form-control" />
                    </div>
                </div>
                <div class="col-lg-4" style="display: none;">
                    <div class="input-group form-group">
                        <asp:Label ID="lblBrand" runat="server" Text="Select Brand" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlBrand" runat="server" DataSourceID="edsddlBrand" DataTextField="BrandName" DataValueField="BrandID" AppendDataBoundItems="true" CssClass="form-control">
                            <asp:ListItem Text="---Select Brand---" Value="0"></asp:ListItem>
                        </asp:DropDownList>
                        <asp:EntityDataSource ID="edsddlBrand" runat="server" ConnectionString="name=DDMSEntities" Where="it.Active = TRUE"
                            DefaultContainerName="DDMSEntities" EnableFlattening="False" EntitySetName="OBRNDs">
                        </asp:EntityDataSource>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-8">
                    <div class="input-group form-group">
                        <asp:Label ID="lblques" runat="server" Text="Enter Question" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtQuestion" runat="server" CssClass="form-control" autocomplete="off" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblSortOrder" runat="server" Text="Sort Order" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtSortOrder" runat="server" CssClass="form-control txtSortOrder allownumericwithdecimal" autocomplete="off" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-4">
                    <div class="input-group form-group">
                        <asp:Label ID="lblMandatory" runat="server" Text="Is Mandatory" CssClass="input-group-addon"></asp:Label>
                        <asp:CheckBox ID="ChkMandatory" runat="server" Checked="false" CssClass="form-control" />
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="input-group form-group" style="margin-bottom: 0px">
                        <asp:Label ID="lblCategory" runat="server" Text="Category" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlCategory" runat="server" CssClass="ddlCategory form-control" onchange="_ChangeSelection(this);">
                            <asp:ListItem Text="Selective" Value="S"></asp:ListItem>
                            <asp:ListItem Text="Descriptive" Value="D"></asp:ListItem>
                            <asp:ListItem Text="Rating" Value="R"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="Select input-group form-group" id="Selection" runat="server">
                        <asp:Label ID="lblSubCat" runat="server" Text="Sub Category" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlSelectivetype" runat="server" CssClass="ddlSelectivetype form-control">
                            <asp:ListItem Text="Any" Value="A"></asp:ListItem>
                            <asp:ListItem Text="Many" Value="M"></asp:ListItem>
                        </asp:DropDownList>
                        <asp:DropDownList ID="ddlDescriptivetype" runat="server" CssClass="ddlDescriptivetype form-control">
                            <asp:ListItem Text="Text" Value="T"></asp:ListItem>
                            <asp:ListItem Text="Numeric" Value="N"></asp:ListItem>
                        </asp:DropDownList>
                        <asp:DropDownList ID="ddlRatingType" runat="server" CssClass="ddlRatingType form-control">
                            <asp:ListItem Text="Text" Value="T"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12">
                    <span style="color: red; font-weight: bold; font-size: small">Note : In Selective & Descriptive Category Enter Posibility Answer Using Comma (,) Seperator.</span>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-8">
                    <div class="input-group form-group">
                        <asp:Label ID="lblPosibility" runat="server" Text="Enter Posibility" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtPosibility" runat="server" CssClass="form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required" autocomplete="off"></asp:TextBox>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCreatedBy" runat="server" Text="Created By" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCreatedBy" Enabled="false" runat="server" CssClass="form-control txtCreatedBy" Style="font-size: small"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCreatedTime" runat="server" Text="Created Time" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCreatedTime" Enabled="false" runat="server" CssClass="form-control txtCreatedTime" Style="font-size: small"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblUpdatedBy" runat="server" Text="Updated By" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtUpdatedBy" Enabled="false" runat="server" CssClass="form-control txtUpdatedBy" Style="font-size: small"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-3">
                    <div class="input-group form-group">
                        <asp:Label ID="lblUpdatedtime" runat="server" Text="Updated Time" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtUpdatedTime" Enabled="false" runat="server" CssClass="form-control txtUpdatedTime" Style="font-size: small"></asp:TextBox>
                    </div>
                </div>
            </div>

            <asp:Button ID="btnSubmit" runat="server" Text="Submit" CssClass="btn btn-default" OnClientClick="return _btnCheck();" OnClick="btnSubmitClick" />
            <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-default" UseSubmitBehavior="false" CausesValidation="false" OnClick="btnCancelClick" />
        </div>
    </div>
</asp:Content>

