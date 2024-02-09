pageextension 50112 ItemPictureExt extends "Item Picture"
{
    actions
    {
        addafter(ExportFile)
        {
            action(CopyToOtherCompany)
            {
                ApplicationArea = All;
                Caption = 'Copy to other company';
                Image = Copy;

                trigger OnAction()
                var
                    CompanyRec: Record Company;
                    Item: Record Item;
                    ClearItemTenantMedia: Codeunit ClearItemTenantMedia;
                begin
                    CompanyRec.Reset();
                    if Page.RunModal(Page::Companies, CompanyRec) = ACTION::LookupOK then begin
                        Item.Reset();
                        Item.ChangeCompany(CompanyRec.Name);
                        if Page.RunModal(Page::"Item List", Item) = ACTION::LookupOK then
                            if Rec.Picture.Count > 0 then begin
                                Item.Picture.Insert(Rec.Picture.Item(1));
                                Item.Modify(true);
                                ClearItemTenantMedia.DeleteCompanyName(Rec.Picture.MediaId, Rec.Picture.Item(1));
                                Message('Item picture copied to company ' + CompanyRec.Name + ' Item No. ' + Item."No.");
                            end;
                    end;
                end;
            }
        }
    }
}

codeunit 50112 ClearItemTenantMedia
{
    Permissions = TableData "Tenant Media" = rimd,
                  TableData "Tenant Media Set" = rimd;

    procedure DeleteCompanyName(PictureID: Guid; MediaId: Guid)
    var
        ItemTenantMedia: Record "Tenant Media";
        ItemTenantMediaSet: Record "Tenant Media Set";
    begin
        if ItemTenantMedia.Get(MediaId) then begin
            ItemTenantMedia."Company Name" := '';
            ItemTenantMedia.Modify();
        end;
        if ItemTenantMediaSet.Get(PictureID, MediaId) then begin
            ItemTenantMediaSet."Company Name" := '';
            ItemTenantMediaSet.Modify();
        end;
    end;
}
