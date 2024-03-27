<%@ Page Title="" Language="C#" MasterPageFile="~/OutletMaster.master" AutoEventWireup="true" CodeFile="CompanyProfile.aspx.cs" Inherits="Marketing_CompanyProfile" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="panel">
        <div class="panel-body">
            <div class="row">
                <div class="col-lg-12">
                    <div class="embed-responsive embed-responsive-4by3">
                        <iframe id="Company_Profile" align="bottom"  class="embed-responsive-item" src="../Document/CompanyProfile.pdf" scrolling="no" frameborder="0" ></iframe>
                    </div>

                </div>
            </div>
        </div>
    </div>

</asp:Content>

