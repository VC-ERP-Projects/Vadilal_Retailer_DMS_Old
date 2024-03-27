<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true"
    CodeFile="WarehouseMaster.aspx.cs" Inherits="Master_WarehouseMaster" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../Scripts/colorbox/colorbox.css" rel="stylesheet" />
    <script type="text/javascript" src="../Scripts/colorbox/jquery.colorbox-min.js"></script>

    <script type="text/javascript">

        function EndRequest() {
            $(".imgLBH").colorbox({ transition: "elastic" });
        }
        $(document).ready(function () {

            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequest);
            $(".imgLBH").colorbox({ transition: "elastic" });

        });
        function _btnCheck() {
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            return $('._masterForm').data('bootstrapValidator').isValid();
        }

    </script>
    <style>
        
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div style="margin-left: 15px">
        <input type="checkbox" name="onoffswitch" class="_auchk" onchange="javascript: setTimeout('__doPostBack(\'\',\'\')', 0)" data-size="large" data-on-text="Add" data-off-text="Update" clientidmode="Static" id="chkMode" runat="server" checked="checked" onserverchange="chkMode_Checked" />
    </div>
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label ID="lblNo" runat="server" Text="No." CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtWhsNo" runat="server" OnTextChanged="txtWhsNo_TextChanged" CssClass="form-control" AutoPostBack="true" autocomplete="off" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="ACEtxtName" runat="server" ServicePath="../WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetWarehouse" MinimumPrefixLength="1" CompletionInterval="10"
                            EnableCaching="false" CompletionSetCount="1" TargetControlID="txtWhsNo">
                        </asp:AutoCompleteExtender>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="Label1" runat="server" Text="Code" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtWhsCode" runat="server" autocomplete="off" CssClass="form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblName" runat="server" Text="Name" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtName" runat="server" autocomplete="off" CssClass="form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblType" runat="server" Text="Type" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlType" runat="server" CssClass="form-control" data-bv-callback="true" data-bv-callback-message="Select Value" data-bv-callback-callback="_ddvalCheck">
                            <asp:ListItem Value="0" Text="--Select--"></asp:ListItem>
                            <asp:ListItem Value="R" Text="Regular"></asp:ListItem>
                            <asp:ListItem Value="T" Text="Return"></asp:ListItem>
                            <asp:ListItem Value="W" Text="Wastage"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblBlock" runat="server" Text="Block" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtBlock" runat="server" CssClass="form-control"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblStreet" runat="server" Text="Street" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtStreet" runat="server" CssClass="form-control"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblLocation" runat="server" Text="Location (Area)" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtLocation" runat="server" CssClass="form-control"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-6">

                    <div class="input-group form-group" style="padding-bottom: 8px">
                        <div style="display: inline; border: 1px solid; padding: 5px; padding-top: 9px; border-radius: 4px">
                            <asp:CheckBox ID="chkIsActive" runat="server" Checked="true" />
                            <asp:Label ID="lblIsActive" runat="server" Text="Is Active" Style="vertical-align: super"></asp:Label>
                        </div>
                        <div style="display: inline; border: 1px solid; padding: 5px; padding-top: 9px; border-radius: 4px">
                            <asp:CheckBox ID="chkDefault" runat="server" />
                            <asp:Label ID="lblDefault" runat="server" Text="Is Default" Style="vertical-align: super"></asp:Label>
                        </div>
                    </div>

                    <div class="input-group form-group">
                        <asp:Label ID="lblPinCode" runat="server" Text="Pin Code" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtPinCode" runat="server" onkeypress="return isNumberKey(event);" onpaste="return false;" CssClass="form-control"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblCity" runat="server" Text="City" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlCity" runat="server" DataSourceID="edsddlCity" DataTextField="CityName" CssClass="form-control"
                            DataValueField="CityID" AppendDataBoundItems="true" OnSelectedIndexChanged="ddlCity_SelectedIndexChanged"
                            AutoPostBack="true" data-bv-callback="true" data-bv-callback-message="Select Value" data-bv-callback-callback="_ddvalCheck">
                            <asp:ListItem Value="0" Text="--Select--"></asp:ListItem>
                        </asp:DropDownList>
                        <asp:EntityDataSource ID="edsddlCity" runat="server" ConnectionString="name=DDMSEntities"
                            DefaultContainerName="DDMSEntities" EnableFlattening="False" EntitySetName="OCTies">
                        </asp:EntityDataSource>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblState" runat="server" Text="State" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlState" runat="server" DataSourceID="edsddlState" DataTextField="StateName" CssClass="form-control"
                            DataValueField="StateID" AppendDataBoundItems="true" data-bv-callback="true" data-bv-callback-message="Select Value" data-bv-callback-callback="_ddvalCheck">
                            <asp:ListItem Value="0" Text="---Select---"></asp:ListItem>
                        </asp:DropDownList>
                        <asp:EntityDataSource ID="edsddlState" runat="server" ConnectionString="name=DDMSEntities"
                            DefaultContainerName="DDMSEntities" EnableFlattening="False" EntitySetName="OCSTs">
                        </asp:EntityDataSource>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblCountry" runat="server" Text="Country" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlCountry" runat="server" DataSourceID="edsddlCountry" DataTextField="CountryName"
                            DataValueField="CountryID" AppendDataBoundItems="true" CssClass="form-control" data-bv-callback="true" data-bv-callback-message="Select Value" data-bv-callback-callback="_ddvalCheck">
                            <asp:ListItem Value="0" Text="---Select---"></asp:ListItem>
                        </asp:DropDownList>
                        <asp:EntityDataSource ID="edsddlCountry" runat="server" ConnectionString="name=DDMSEntities"
                            DefaultContainerName="DDMSEntities" EnableFlattening="False" EntitySetName="OCRies">
                        </asp:EntityDataSource>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblContactPerson" runat="server" Text="Contact Person" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtContactPerson" runat="server" CssClass="form-control"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblPhone" runat="server" Text="Phone - Mobile" CssClass="input-group-addon"></asp:Label>
                        <table width="100%">
                            <tr>
                                <td width="50%">
                                    <asp:TextBox ID="txtPhone" runat="server" placeholder="Phone" onkeypress="return isNumberKey(event);" CssClass="form-control" onpaste="return false;"></asp:TextBox></td>
                                <td width="50%">
                                    <asp:TextBox ID="txtMobile" runat="server" placeholder="Mobile" onkeypress="return isNumberKey(event);" CssClass="form-control" onpaste="return false;"></asp:TextBox></td>
                            </tr>
                        </table>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-12 _textArea">
                    <div class="input-group form-group">
                        <asp:Label ID="lblNotes" runat="server" Text="Notes" CssClass="lbl_desc input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtNotes" runat="server" TextMode="MultiLine" CssClass="form-control"></asp:TextBox>
                    </div>
                </div>
            </div>
            <asp:Button ID="btnSubmit" runat="server" Text="Submit" CssClass="btn btn-default" OnClientClick="return _btnCheck();" OnClick="btnSubmitClick" />
            <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-default" UseSubmitBehavior="false" CausesValidation="false"
                OnClick="btnCancelClick" />
        </div>
    </div>
</asp:Content>
