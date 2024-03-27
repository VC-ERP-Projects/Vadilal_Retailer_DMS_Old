<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="EmailSMS.aspx.cs" Inherits="Marketing_EmailSMS" %>


<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">
        function _btnCheck() {
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            return $('._masterForm').data('bootstrapValidator').isValid();
        }

        $(function () {
            laod();
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler2);
        });

        function EndRequestHandler2(sender, args) {
            laod();
        }

        function laod() {
            $('.fht-tbody').css('max-height', '400px');
            $(".txtEmpSearch").keyup(function () {
                var word = this.value;
                $(".gvEmployee > tbody tr").each(function () {
                    if ($(this).find("td").text().toUpperCase().indexOf(word.toUpperCase()) >= 0)
                        $(this).show();
                    else
                        $(this).hide();
                });
            });
        }

        function CheckMain(chk) {
            if (chk == undefined) {
                if ($('.chkCheck').length == $('.chkCheck:checked').length)
                    $('.chkMain').prop('checked', true);
                else
                    $('.chkMain').prop('checked', false);
            }
            else {
                if ($(chk).is(':checked')) {
                    $('.chkCheck').prop('checked', true);
                }
                else {
                    $('.chkCheck').prop('checked', false);
                }
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
            <div class="row" style="margin-bottom: 0px">
                <div class="col-lg-12" style="margin-bottom:-10px">
                    <div class="input-group form-group">
                        <asp:Label ID="lblSubject" runat="server" CssClass="input-group-addon" Text="Subject"></asp:Label>
                        <asp:TextBox ID="txtSubject" runat="server" CssClass="form-control" AutoPostBack="true"
                            autocomplete="off" OnTextChanged="txtSubject_TextChanged" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="ACEtxtSubject" runat="server" ServicePath="../WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetEmailSubject" MinimumPrefixLength="1" CompletionInterval="10"
                            Enabled="false" EnableCaching="false" CompletionSetCount="1" TargetControlID="txtSubject">
                        </asp:AutoCompleteExtender>
                    </div>
                </div>
            </div>
            <div class="row">

                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFrequency" runat="server" CssClass="input-group-addon" Text="Frequency"></asp:Label>
                        <table width="100%">
                            <tr>
                                <td>
                                    <asp:TextBox ID="txtDay" runat="server" CssClass="form-control" placeholder="Day" data-bv-notempty="true" data-bv-notempty-message="Field is required" onkeypress="return isNumberKey(event);"></asp:TextBox></td>
                                <td>
                                    <asp:TextBox ID="txtTime" runat="server" CssClass="form-control" placeholder="Time" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox></td>
                                <asp:MaskedEditExtender ID="Authmee" runat="server" TargetControlID="txtTime" MaskType="Time"
                                    Mask="99:99:99">
                                </asp:MaskedEditExtender>
                            </tr>
                        </table>

                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label ID="lblIsActive" runat="server" CssClass="input-group-addon" Text="Is Active"></asp:Label>
                        <asp:CheckBox ID="chkIsActive" runat="server" CssClass="form-control" Checked="true" />
                    </div>
                </div>

            </div>
            <div class="row">
                <div class="col-lg-12  _textArea">
                    <div class="input-group form-group">
                        <asp:Label ID="lblQuery" runat="server" CssClass="input-group-addon" Text="Query"> </asp:Label>
                        <asp:TextBox ID="txtQuery" runat="server" CssClass="form-control" TextMode="MultiLine" Style="resize: none;" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                    </div>
                </div>
            </div>
            <asp:TextBox runat="server" placeholder="Search here" ID="txtEmpSearch" CssClass="txtEmpSearch form-control" />
            
            <asp:GridView ID="gvEmployee" runat="server" EmptyDataText="No Employee Found." AutoGenerateColumns="False" CssClass="gvEmployee table">
                <HeaderStyle CssClass="table-header-gradient" />
                <Columns>
                    <asp:TemplateField HeaderText="">
                        <HeaderTemplate>
                            <input type="checkbox" name="chkMain" id="chkMain" class="chkMain" runat="server" checked="checked" onchange="CheckMain(this);" />
                        </HeaderTemplate>
                        <ItemTemplate>
                            <input type="checkbox" name="chkCheck" id="chkCheck" class="chkCheck" runat="server" checked='<%#Eval("Active" ) %>' onchange="CheckMain();" />
                        </ItemTemplate>
                        <ItemStyle Width="8%" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Emp ID" Visible="false">
                        <ItemTemplate>
                            <asp:Label ID="lblEmpID" runat="server" Text='<%#Eval("EmpID" ) %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Group">
                        <ItemTemplate>
                            <asp:Label ID="lblGroup" runat="server" Text='<%#Eval("OGRP.EmpGroupName") %>'>></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Employee Code">
                        <ItemTemplate>
                            <asp:Label ID="lblEmpCode" runat="server" Text='<%#Eval("EmpCode") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Employee Name">
                        <ItemTemplate>
                            <asp:Label ID="lblEmpName" runat="server" Text='<%#Eval("Name") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Email">
                        <ItemTemplate>
                            <asp:Label ID="lblEmail" runat="server" Text='<%#Eval("WorkEmail") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
            <asp:Button ID="btnSubmit" CssClass="btn btn-default" runat="server" Text="Submit" OnClick="btnSubmit_Click" OnClientClick="return _btnCheck();" />
            <asp:Button ID="btnCancel" UseSubmitBehavior="false" CausesValidation="false" CssClass="btn btn-default" runat="server" Text="Cancel" OnClick="btnCancel_Click" />
        </div>
    </div>
</asp:Content>
