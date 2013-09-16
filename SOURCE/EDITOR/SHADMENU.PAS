{$I DEFINES.INC}
unit ShadMenu;
{***********************************************************************
 TMenuBoxShadow  SHADOW CLASS
 This shadow class patches an undesirbale behavior in the TMenuBar Class
 by patching the GetPalette method of TMenuBox Class.  TMenuBar objects
 insert a TMneuBox object into the Owner of the TMenuBar object to display
 submenus.  This works fine when the TMenuBar object's owner is the
 desktop.  TMenuBox's palette is mapped to the desktop palette.  However,
 when a TMenuBar object is inserted into something other than the desktop,
 the palettes do not match.  A descendant of TMenuBar can be created that
 uses a palette that matches where it is inserted, but TMenuBar will still
 insert a TMenuBox object with a palette matched to TDesktop not to the
 actual owner where the MenuBaar is inserted.  TNewMenuBox is a shadow
 class for TMenuBox.  It modifies the behavior of the TMenuBox class'
 GetPalette Method.  The new shadow GetPaalette returns the Palette of
 the ParentMenu if there is one, and if not then it returns the normal
 Palette of TMenuBox.

 ***********************************************************************}
{$X+}
interface
	{Nothing Needed Here}
implementation
	uses Menus,views,objects,Shadow;
	type
		TMenuBoxShadow = object(TMenuBox)
			function GetPalette:PPalette; virtual;
			end;
	function TMenuBoxShadow.GetPalette:PPalette;
		begin
		if ParentMenu=Nil then
			GetPalette := TMenuView.GetPalette
		else
			GetPalette := ParentMenu^.GetPalette;
		end;

	begin
{ Install the New GetPallette }
	ReplaceMethod(typeof(TMenuBox),@TMenuBox.GetPalette,@TMenuBoxShadow.GetPalette);
	end.
