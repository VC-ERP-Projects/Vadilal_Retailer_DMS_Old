<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="ClientFeedBack.aspx.cs" Inherits="Marketing_ClientFeedBack" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
   <script type="text/javascript">
       function _btnCheck() {
           if (!$('._masterForm').data('bootstrapValidator').isValid())
               $('._masterForm').bootstrapValidator('validate');

           return $('._masterForm').data('bootstrapValidator').isValid();
       }



    </script>
    <style>
        /* Rating */
        .ratingStar {
            font-size: 0pt;
            width: 13px;
            height: 12px;
            margin: 0px;
            padding: 0px;
            cursor: pointer;
            display: block;
            background-repeat: no-repeat;
        }

        .filledRatingStar {
            background-image: url(../Images/FilledStar.png);
        }

        .emptyRatingStar {
            background-image: url(../Images/EmptyStar.png);
        }

        .savedRatingStar {
            background-image: url(../Images/SavedStar.png);
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel panel-default">
        <div class="panel-body">
            <div class="row _masterForm">
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label ID="lblFeedbackFrom" runat="server" Text="FeedBack From" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlFeedBackFrom" runat="server" AppendDataBoundItems="True" AutoPostBack="True" OnSelectedIndexChanged="ddlFeedBackFrom_SelectedIndexChanged" CssClass="form-control">
                            <asp:ListItem Value="D" Text="Dealer" Selected="True"></asp:ListItem>
                            <asp:ListItem Value="C" Text="Customer"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblName" runat="server" Text="Name" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtName" runat="server" Enabled="false" data-bv-notempty="true" data-bv-notempty-message="Field is required"
                            OnTextChanged="txtName_TextChanged" AutoPostBack="True" CssClass="form-control"></asp:TextBox>
                        <asp:AutoCompleteExtender OnClientShown="resetPosition" CompletionListCssClass="CompletionListClass" ID="acettxtCustomerName" runat="server" ServicePath="../WebService.asmx"
                            UseContextKey="true" ServiceMethod="GetCustomer" MinimumPrefixLength="1" CompletionInterval="10"
                            Enabled="false" EnableCaching="true" CompletionSetCount="1" TargetControlID="txtName">
                        </asp:AutoCompleteExtender>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblWebsite" runat="server" Text="Website" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtWebsite" runat="server" Enabled="false" CssClass="form-control"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="Label2" runat="server" Text="Sales Rep." CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList runat="server" ID="ddlSR" DataTextField="Name" DataValueField="EmpID" CssClass="form-control" data-bv-callback="true" data-bv-callback-message="Select Value" data-bv-callback-callback="_ddvalCheck">
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="input-group form-group">
                        <asp:Label ID="lblContactName" runat="server" Text="Contact Name" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtContactName" runat="server" Enabled="false" CssClass="form-control"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblPhoneNumber" runat="server" Text="Phone Number" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtPhoneNumber" runat="server" Enabled="false" CssClass="form-control"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblEmailAddress" runat="server" Text="E-Mail" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtEmail" runat="server" Enabled="false" CssClass="form-control" data-bv-emailaddress="true"></asp:TextBox>
                    </div>
                    <div class="input-group form-group">
                        <asp:Label ID="lblFeedBackType" runat="server" Text="FeedBack Type" CssClass="input-group-addon"></asp:Label>
                        <asp:DropDownList ID="ddlFeedBackType" runat="server" AppendDataBoundItems="True" AutoPostBack="True" OnSelectedIndexChanged="ddlFeedBackType_SelectedIndexChanged" CssClass="form-control" data-bv-callback="true" data-bv-callback-message="Select Value" data-bv-callback-callback="_ddvalCheck">
                            <asp:ListItem Value="0" Text="---Select---"></asp:ListItem>
                            <asp:ListItem Value="P" Text="Product"></asp:ListItem>
                            <asp:ListItem Value="S" Text="Service"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>

            </div>
            <div class="row">
                <div class="col-lg-12 _textArea">
                    <div class="input-group form-group">
                        <asp:Label ID="lblNotes" runat="server" Text="Notes" CssClass="input-group-addon"></asp:Label>
                        <asp:TextBox ID="txtNotes" runat="server" TextMode="MultiLine" CssClass="form-control"></asp:TextBox>
                    </div>
                </div>
            </div>
            <asp:GridView ID="gvFeedBackQue" runat="server" AutoGenerateColumns="False" EmptyDataText="No Question Found." CssClass="table"
                HeaderStyle-CssClass="table-header-gradient" DataKeyNames="QuesID" AllowPaging="false" AllowSorting="false">
                <Columns>
                    <asp:TemplateField HeaderText="No.">
                        <ItemTemplate>
                            <asp:Label ID="lblNo" Text='<% # Container.DataItemIndex + 1%>' runat="server" />
                            <asp:Label runat="server" ID="lblQuesID" Text='<%# Bind("QuesID") %>' Visible="false"></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Question Name">
                        <ItemTemplate>
                            <asp:Label ID="lblQuesName" runat="server" Text='<%# Bind("QuesName") %>'></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Notes">
                        <ItemTemplate>
                            <asp:TextBox ID="txtNotes" runat="server" CssClass="form-control"></asp:TextBox>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Rating">
                        <ItemTemplate>
                            <asp:Rating ID="ratgvFeedbackQue" runat="server" MaxRating="5" StarCssClass="ratingStar" WaitingStarCssClass="savedRatingStar" FilledStarCssClass="filledRatingStar" EmptyStarCssClass="emptyRatingStar" Style="float: inherit;">
                            </asp:Rating>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
            <asp:Button ID="btnSubmit" runat="server" Text="Submit" CssClass="btn btn-default" OnClick="btnSubmit_Click" OnClientClick="return _btnCheck();" />
            <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-default" OnClick="btnCancel_Click" UseSubmitBehavior="false" CausesValidation="false"/>
        </div>
    </div>
</asp:Content>

