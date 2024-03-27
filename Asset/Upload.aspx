<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Upload.aspx.cs" Inherits="Asset_Upload" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="../Scripts/jquery-1.9.1.js" type="text/javascript"></script>
    <script src="../Scripts/model/jquery.simplemodal-1.4.4.js" type="text/javascript"></script>
    <link href="css/index.css" rel="stylesheet" type="text/css" />
    <link href="css/base.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript">

        function ModelMsg(Text, ECode) {
            if (ECode == undefined)
                ECode = "1";
            $.modal(Text, ECode);
        }

    </script>
</head>
<body>
    <form id="form1" runat="server">
        <fieldset style="height: 86px; border: 1px solid black;">
            <legend style="font-size: 18px; color: black;">Upload Your File Here</legend>
            <asp:FileUpload ID="flUpload" runat="server" Style="margin-bottom: 6%" />
            <asp:LinkButton Text="Submit" ID="btnSubmit" runat="server" OnClick="btnSubmit_Click" CssClass="lnk_btn" />
            <asp:LinkButton Text="Cancel" ID="btnCancel" runat="server" OnClientClick="parent.$.colorbox.close();" CssClass="lnk_btn" />
        </fieldset>
    </form>
</body>
</html>
