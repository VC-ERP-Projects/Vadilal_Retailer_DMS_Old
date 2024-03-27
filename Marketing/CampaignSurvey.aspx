<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true"
    CodeFile="CampaignSurvey.aspx.cs" Inherits="Marketing_CampaignSurvey" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <script type="text/javascript">
        function _btnCheck() {
            if (!$('._masterForm').data('bootstrapValidator').isValid())
                $('._masterForm').bootstrapValidator('validate');

            return $('._masterForm').data('bootstrapValidator').isValid();
        }

        

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label ID="lblCampaign" runat="server" Text="Campaign" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlCampaign" TabIndex="1" runat="server" AppendDataBoundItems="True" CssClass="form-control" data-bv-callback="true" data-bv-callback-message="Select Value" data-bv-callback-callback="_ddvalCheck"
                            DataSourceID="edsddlCampignQue" DataTextField="CampaignName" DataValueField="CampaignID" OnSelectedIndexChanged="ddlCampaign_SelectedIndexChanged" AutoPostBack="true">
                            <asp:ListItem Value="0" Text="---Select---"></asp:ListItem>
                        </asp:DropDownList>
                        <asp:EntityDataSource ID="edsddlCampignQue" runat="server" ConnectionString="name=DDMSEntities"
                            Where="it.ParentID = @ParentID and it.Active = true" DefaultContainerName="DDMSEntities" EnableFlattening="False" EntitySetName="OCMPs">
                            <WhereParameters>
                                <asp:SessionParameter Name="ParentID" SessionField="ParentID" DbType="Decimal" />
                            </WhereParameters>
                        </asp:EntityDataSource>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblCompanyName" runat="server" Text="Company Name" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtCompanyName" runat="server" TabIndex="2" CssClass="form-control"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblIndustry" runat="server" Text="Industry" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtIndustry" runat="server" TabIndex="3" CssClass="form-control"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblWebsite" runat="server" Text="Website" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtWebsite" runat="server" TabIndex="4" CssClass="form-control"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblContactName" runat="server" Text="Contact Name" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtContactName" runat="server" TabIndex="5" CssClass="form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label ID="lblPhoneNumber" runat="server" Text="Phone Number" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtPhoneNumber" runat="server" TabIndex="6" CssClass="form-control"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblEmailAddress" runat="server" Text="E-Mail" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtEmail" runat="server" TabIndex="7" CssClass="form-control" data-bv-notempty="true" data-bv-emailaddress="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblFollowUpDate" runat="server" Text="Follow-Up Date" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtFollowUpDate" runat="server" TabIndex="8" MaxLength="10" onkeyup="return ValidateDate(this);" CssClass="datepick form-control" data-bv-notempty="true" data-bv-notempty-message="Field is required"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblNewLetterSubscription" runat="server" Text="Subscription to Newsletter" CssClass="input-group-addon"></asp:Label>
                        <asp:CheckBox ID="chkNewLetterSubscription" runat="server" TabIndex="9" Checked="true" CssClass="form-control"/>
                    </div>
                </div>

            </div>
            <div class="row">
                <div class="col-lg-12 _textArea">
                    <div class="input-group form-group">
                        <asp:Label ID="lblNotes" runat="server" Text="Notes" CssClass="input-group-addon"></asp:Label>
                <asp:TextBox ID="txtNotes" runat="server" TabIndex="10" TextMode="MultiLine" CssClass="form-control"></asp:TextBox>
                    </div>
                </div>
            </div>
            <asp:GridView ID="gvCampaignQuestion" runat="server" AutoGenerateColumns="False" EmptyDataText="No Question Found." PageSize="10"
        AllowSorting="True" AllowPaging="True" HeaderStyle-CssClass="table-header" DataKeyNames="QuesID" DataSourceID="edsgvCampaignQue" CssClass="only_radio table" Visible="false">
        <Columns>
            <asp:TemplateField HeaderText="No.">
                <ItemTemplate>
                    <asp:Label ID="lblNo" Text='<% # Container.DataItemIndex + 1%>' runat="server" />
                    <asp:Label runat="server" ID="lblQuesID" Text='<%# Bind("QuesID") %>' Visible="false"></asp:Label>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Question Name" SortExpression="QuesName">
                <ItemTemplate>
                    <asp:Label ID="Label1" runat="server" Text='<%# Bind("QuesName") %>'></asp:Label>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Action">
                <ItemTemplate>
                    <asp:RadioButton ID="rbAnsYes" Text="Yes" GroupName="Ans" runat="server"
                        AutoPostBack="true" />
                    <asp:RadioButton ID="rbAnsNo" Text="No" GroupName="Ans" runat="server"
                        AutoPostBack="true" />
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
    </asp:GridView>
    <asp:EntityDataSource ID="edsgvCampaignQue" runat="server" ConnectionString="name=DDMSEntities"
        DefaultContainerName="DDMSEntities" EnableFlattening="False" EntitySetName="OQUS"
        Where="it.DocType == 'C' and it.Active = true">
    </asp:EntityDataSource>
            <asp:Button ID="btnSubmit" runat="server" Text="Submit" TabIndex="11" CssClass="btn btn-default"
                OnClick="btnSubmit_Click" OnClientClick="return _btnCheck();" />
            <asp:Button ID="btnCancel" runat="server" Text="Cancel" TabIndex="12" CssClass="btn btn-default" OnClick="btnCancel_Click" UseSubmitBehavior="false" CausesValidation="false"/>
        </div>
    </div>
    
    
   
</asp:Content>
