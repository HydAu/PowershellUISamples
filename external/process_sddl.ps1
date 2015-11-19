# origin https://www.pierschel.com/de/software-blog/69-csharp-securityeditor
# https://msdn.microsoft.com/en-us/library/windows/desktop/aa379570%28v=vs.85%29.aspx
# https://msdn.microsoft.com/en-us/library/system.runtime.interopservices%28v=vs.100%29.aspx

Add-Type -TypeDefinition @"

using System;
using System.Runtime.InteropServices;
using System.Windows;
using System.Windows.Forms;
/// using System.Windows.Interop;

[Flags]
public enum SI_SECURITY_INFORMATION : uint
{
    Owner = 0x00000001,
    Group = 0x00000002,
    Dacl = 0x00000004,
    Sacl = 0x00000008,
    Label = 0x00000010,
    ProtectedDacl = 0x80000000,
    ProtectedSacl = 0x40000000,
    UnprotectedDacl = 0x20000000,
    UnprotectedSacl = 0x10000000
}
 
/// <summary>
/// A set of bit flags that determine the editing options available to the user. This member can be a combination of the following values.
/// </summary>
[Flags]
public enum SI_OBJECT_FLAGS : uint
{
    /// <summary>
    /// If this flag is set, the Advanced button is displayed on the basic security property page.
    /// If the user clicks this button, the system displays an advanced security property sheet that enables advanced editing of the discretionary access control list (DACL) of the object.
    /// Combine this flag with the SI_EDIT_AUDITS, SI_EDIT_OWNER, and SI_EDIT_PROPERTIES flags to enable editing of the object's SACL, owner, and object-specific access control entries (ACEs).
    /// </summary>
    SI_ADVANCED = 0x00000010,
     
    /// <summary>
    /// If this flag is set, a shield is displayed on the Edit button of the advanced Auditing pages. For NTFS objects, this flag is requested when the user does not have READ_CONTROL or ACCESS_SYSTEM_SECURITY access.
    /// </summary>
    /// <remarks>Windows Server 2003 and Windows XP:  This flag is not supported.</remarks>
    SI_AUDITS_ELEVATION_REQUIRED = 0x02000000,
     
    /// <summary>
    /// Indicates that the object is a container. If this flag is set, the access control editor enables the controls relevant to the inheritance of permissions onto child objects.
    /// </summary>
    SI_CONTAINER = 0x00000004,
     
    /// <summary>
    /// If this flag is set, the system disables denying an ACE. Clients of the access control editor must implement the ISecurityInformation4 interface to set this flag.
    /// </summary>
    /// <remarks>Windows Server 2008 R2, Windows 7, Windows Server 2008, Windows Vista, Windows Server 2003, and Windows XP:  This flag is not supported.</remarks>
    SI_DISABLE_DENY_ACE = 0x80000000,
     
    /// <summary>
    /// Combines the SI_EDIT_PERMS, SI_EDIT_OWNER, and SI_EDIT_AUDITS flags.
    /// </summary>
    SI_EDIT_ALL = SI_EDIT_PERMS | SI_EDIT_OWNER | SI_EDIT_AUDITS,
     
    /// <summary>
    /// If this flag is set and the user clicks the Advanced button, the system displays an advanced security property sheet that includes an Auditing property page for editing the object's SACL. To display the Advanced button, set the SI_ADVANCED flag.
    /// </summary>
    SI_EDIT_AUDITS = 0x00000002,
     
    /// <summary>
    /// If this flag is set, the Effective Permissions page is displayed. This flag is ignored if the ISecurityInformation object that initialized the access control editor does not implement the IEffectivePermission interface.
    /// </summary>
    SI_EDIT_EFFECTIVE = 0x00020000,
     
    /// <summary>
    /// If this flag is set and the user clicks the Advanced button, the system displays an advanced security property sheet that includes an Owner property page for changing the object's owner. To display the Advanced button, set the SI_ADVANCED flag.
    /// </summary>
    SI_EDIT_OWNER = 0x00000001,
     
    /// <summary>
    /// This is the default value. The basic security property page always displays the controls for basic editing of the object's DACL. To disable these controls, set the SI_READONLY flag.
    /// </summary>
    SI_EDIT_PERMS = 0x00000000, // always implied public const int SI_EDIT_OWNER = 0x00000001;
     
    /// <summary>
    /// If this flag is set, the system enables controls for editing ACEs that apply to the object's property sets and properties. These controls are available only on the property sheet displayed when the user clicks the Advanced button.
    /// </summary>
    SI_EDIT_PROPERTIES = 0x00000080,
     
    /// <summary>
    /// If this flag is set, the system enables editing attributes. Clients of the access control editor must implement the ISecurityInformation4 interface to set this flag.
    /// </summary>
    /// <remarks>Windows Server 2008 R2, Windows 7, Windows Server 2008, Windows Vista, Windows Server 2003, and Windows XP:  This flag is not supported.</remarks>
    SI_ENABLE_CENTRAL_POLICY = 0x40000000,
     
    /// <summary>
    /// If this flag is set, the system enables editing attributes. Clients of the access control editor must implement the ISecurityInformation4 interface to set this flag.
    /// </summary>
    /// <remarks>Windows Server 2008 R2, Windows 7, Windows Server 2008, Windows Vista, Windows Server 2003, and Windows XP:  This flag is not supported.
    SI_ENABLE_EDIT_ATTRIBUTE_CONDITION = 0x20000000,
    /// <summary>
    /// Indicates that the access control editor cannot read the DACL but might be able to write to the DACL. If a call to the ISecurityInformation::GetSecurity method returns AccessDenied, the user can try to add a new ACE, and a more appropriate warning is displayed.
    /// </summary>
    SI_MAY_WRITE = 0x10000000, //not sure if user can write permission
    /// <summary>
    /// If this flag is set, the access control editor hides the check box that allows inheritable ACEs to propagate from the parent object to this object. If this flag is not set, the check box is visible.
    /// The check box is clear if the SE_DACL_PROTECTED flag is set in the object's security descriptor. In this case, the object's DACL is protected from being modified by inheritable ACEs.
    /// If the user clears the check box, any inherited ACEs in the security descriptor are deleted or converted to noninherited ACEs. Before proceeding with this conversion, the system displays a warning message box to confirm the change.
    /// </summary>
    SI_NO_ACL_PROTECT = 0x00000200,
    /// <summary>
    /// If this flag is set, the access control editor hides the Special Permissions tab on the Advanced Security Settings page.
    /// </summary>
    SI_NO_ADDITIONAL_PERMISSION = 0x00200000,
    /// <summary>
    /// If this flag is set, the access control editor hides the check box that controls the NO_PROPAGATE_INHERIT_ACE flag. This flag is relevant only when the SI_ADVANCED flag is also set.
    /// </summary>
    SI_NO_TREE_APPLY = 0x00000400,
    /// <summary>
    /// When set, indicates that the guidObjectType member of the SI_OBJECT_INFO structure is valid. This is set in comparisons with object-specific ACEs in determining whether the ACE applies to the current object.
    /// </summary>
    SI_OBJECT_GUID = 0x00010000,
    /// <summary>
    /// If this flag is set, a shield is displayed on the Edit button of the advanced Owner page. For NTFS objects, this flag is requested when the user does not have WRITE_OWNER access. This flag is valid only if the owner page is requested.
    /// </summary>
    /// <remarks>Windows Server 2003 and Windows XP:  This flag is not supported.</remarks>
    SI_OWNER_ELEVATION_REQUIRED = 0x04000000,
    /// <summary>
    /// If this flag is set, the user cannot change the owner of the object. Set this flag if SI_EDIT_OWNER is set but the user does not have permission to change the owner.
    /// </summary>
    SI_OWNER_READONLY = 0x00000040,
    /// <summary>
    /// Combine this flag with SI_CONTAINER to display a check box on the owner page that indicates whether the user intends the new owner to be applied to all child objects as well as the current object. The access control editor does not perform the recursion; the recursion should be performed by the application in ISecurityInformation::SetSecurity.
    /// </summary>
    SI_OWNER_RECURSE = 0x00000100,
    /// <summary>
    /// If this flag is set, the pszPageTitle member is used as the title of the basic security property page. Otherwise, a default title is used.
    /// </summary>
    SI_PAGE_TITLE = 0x00000800,
    /// <summary>
    /// If this flag is set, an image of a shield is displayed on the Edit button of the simple and advanced Permissions pages. For NTFS objects, this flag is requested when the user does not have READ_CONTROL or WRITE_DAC access.
    /// </summary>
    /// <remarks>Windows Server 2003 and Windows XP:  This flag is not supported.</remarks>
    SI_PERMS_ELEVATION_REQUIRED = 0x01000000,
    /// <summary>
    /// If this flag is set, the editor displays the object's security information, but the controls for editing the information are disabled. This flag cannot be combined with the SI_VIEW_ONLY flag.
    /// </summary>
    SI_READONLY = 0x00000008,
    /// <summary>
    /// If this flag is set, the Default button is displayed. If the user clicks this button, the access control editor calls the ISecurityInformation::GetSecurity method to retrieve an application-defined default security descriptor. The access control editor uses this security descriptor to reinitialize the property sheet, and the user is allowed to apply the change or cancel.
    /// </summary>
    SI_RESET = 0x00000020, //equals to SI_RESET_DACL|SI_RESET_SACL|SI_RESET_OWNER public const int SI_OWNER_READONLY = 0x00000040;
    /// <summary>
    /// When set, this flag displays the Reset Defaults button on the Permissions page.
    /// </summary>
    SI_RESET_DACL = 0x00040000,
    /// <summary>
    /// When set, this flag displays the Reset permissions on all child objects and enable propagation of inheritable permissions check box in the Permissions page of the Access Control Settings window. If this check box is selected when the user clicks the Apply button, a bitwise-OR operation is performed on the SecurityInformation parameter of ISecurityInformation::SetSecurity with SI_RESET_DACL_TREE. This function does not reset the permissions and enable propagation of inheritable permissions; the implementation of ISecurityInformation must do this.
    /// </summary>
    SI_RESET_DACL_TREE = 0x00004000,
    /// <summary>
    /// When set, this flag displays the Reset Defaults button on the Owner page.
    /// </summary>
    SI_RESET_OWNER = 0x00100000,
    /// <summary>
    /// When set, this flag displays the Reset Defaults button on the Auditing page.
    /// </summary>
    SI_RESET_SACL = 0x00080000,
    /// <summary>
    /// When set, this flag displays the Reset auditing entries on all child objects and enables propagation of the inheritable auditing entries check box in the Auditing page of the Access Control Settings window. If this check box is selected when the user clicks the Apply button, a bitwise-OR operation is performed on the SecurityInformation parameter of ISecurityInformation::SetSecurity with SI_RESET_SACL_TREE. This function does not reset the permissions and enable propagation of inheritable permissions; the implementation of ISecurityInformation must do this.
    /// </summary>
    SI_RESET_SACL_TREE = 0x00008000,
    /// <summary>
    /// If this flag is set, an image of a shield is displayed on the Change button of the Scope attribute. For NTFS objects, this flag is requested when the user does not have READ_CONTROL or WRITE_DAC access. Clients of the access control editor must implement the ISecurityInformation4 interface to set this flag.
    /// </summary>
    /// <remarks>Windows Server 2008 R2, Windows 7, Windows Server 2008, Windows Vista, Windows Server 2003, and Windows XP:  This flag is not supported.</remarks>
    SI_SCOPE_ELEVATION_REQUIRED = 0x08000000,
    /// <summary>
    /// Set this flag if the pszServerName computer is known to be a domain controller. If this flag is set, the domain name is included in the scope list of the Add Users and Groups dialog box. Otherwise, the pszServerName computer is used to determine the scope list of the dialog box.
    /// </summary>
    SI_SERVER_IS_DC = 0x00001000,
    /// <summary>
    /// This flag is set by the access control editor client to display read-only versions of the access control editor dialog boxes. These versions of the dialog boxes do not allow editing of the associated object's permissions. Clients of the access control editor must implement the ISecurityInformation3 interface to set this flag.
    /// This flag cannot be combined with the SI_READONLY flag. Windows Server 2003 and Windows XP:  This flag is not supported.
    /// </summary>
    SI_VIEW_ONLY = 0x00400000
}
 
/// <summary>
/// A set of bit flags that indicate the property page being initialized. This value is zero if the basic security page is being initialized. Otherwise, it is a combination of the following values.
/// </summary>
[Flags]
public enum SI_ACCESS_RIGHT_FLAG
{
    /// <summary>
    /// The Advanced Security property sheet is being initialized.
    /// </summary>
    SI_ADVANCED = 0x00000010,
     
    /// <summary>
    /// The Advanced Security property sheet includes the Audit property page.
    /// </summary>
    SI_EDIT_AUDITS = 0x00000002,
     
    /// <summary>
    /// The Advanced Security property sheet enables editing of ACEs that apply to the properties and property sets of the object.
    /// </summary>
    SI_EDIT_PROPERTIES = 0x00000080
}
 
/// <summary>
/// The ACCESS_MASK data type is a DWORD value that defines standard, specific, and generic rights. These rights are used in access control entries (ACEs) and are the primary means of specifying the requested or granted access to an object.
/// </summary>
[Flags]
public enum SI_ACCESS_MASK : uint
{
    /// <summary>
    /// Delete access.
    /// Bit 16
    /// </summary>
    DELETE = 0x00010000,
     
    /// <summary>
    /// Read access to the owner, group, and discretionary access control list (DACL) of the security descriptor.
    /// Bit 17
    /// </summary>
    READ_CONTROL = 0x00020000,
     
    /// <summary>
    /// Write access to the DACL.
    /// Bit 18
    /// </summary>
    WRITE_DAC = 0x00040000,
     
    /// <summary>
    /// Write access to owner.
    /// Bit 19
    /// </summary>
    WRITE_OWNER = 0x00080000,
     
    /// <summary>
    /// Synchronize access.
    /// Bit 20
    /// </summary>
    SYNCHRONIZE = 0x00100000,
     
    STANDARD_RIGHTS_REQUIRED = 0x000F0000,
    STANDARD_RIGHTS_READ = READ_CONTROL,
    STANDARD_RIGHTS_WRITE = READ_CONTROL,
    STANDARD_RIGHTS_EXECUTE = READ_CONTROL,
    STANDARD_RIGHTS_ALL = 0x001F0000,
    SPECIFIC_RIGHTS_ALL = 0x0000FFFF,
     
    /// <summary>
    /// Access system security (ACCESS_SYSTEM_SECURITY). It is used to indicate access to a system access control list (SACL). This type of access requires the calling process to have the SE_SECURITY_NAME (Manage auditing and security log) privilege. If this flag is set in the access mask of an audit access ACE (successful or unsuccessful access), the SACL access will be audited.
    /// Bit 24
    /// </summary>
    ACCESS_SYSTEM_SECURITY = 0x01000000,
     
    MAXIMUM_ALLOWED = 0x02000000,
    GENERIC_READ = 0x80000000,
    GENERIC_WRITE = 0x40000000,
    GENERIC_EXECUTE = 0x20000000,
    GENERIC_ALL = 0x10000000,
    DESKTOP_READOBJECTS = 0x00000001,
    DESKTOP_CREATEWINDOW = 0x00000002,
    DESKTOP_CREATEMENU = 0x00000004,
    DESKTOP_HOOKCONTROL = 0x00000008,
    DESKTOP_JOURNALRECORD = 0x00000010,
    DESKTOP_JOURNALPLAYBACK = 0x00000020,
    DESKTOP_ENUMERATE = 0x00000040,
    DESKTOP_WRITEOBJECTS = 0x00000080,
    DESKTOP_SWITCHDESKTOP = 0x00000100,
    WINSTA_ENUMDESKTOPS = 0x00000001,
    WINSTA_READATTRIBUTES = 0x00000002,
    WINSTA_ACCESSCLIPBOARD = 0x00000004,
    WINSTA_CREATEDESKTOP = 0x00000008,
    WINSTA_WRITEATTRIBUTES = 0x00000010,
    WINSTA_ACCESSGLOBALATOMS = 0x00000020,
    WINSTA_EXITWINDOWS = 0x00000040,
    WINSTA_ENUMERATE = 0x00000100,
    WINSTA_READSCREEN = 0x00000200,
    WINSTA_ALL_ACCESS = 0x0000037F
}
 
/// <summary>
/// A set of bit flags that indicate where the access right is displayed. This member can be a combination of the following.
/// </summary>
[Flags]
public enum SI_ACCESS_FLAG
{
    /// <summary>
    /// The access right is displayed on the advanced security pages.
    /// </summary>
    SI_ACCESS_SPECIFIC = 0x00010000,
     
    /// <summary>
    /// The access right is displayed on the basic security page.
    /// </summary>
    SI_ACCESS_GENERAL = 0x00020000,
     
    /// <summary>
    /// Indicates an access right that applies only to containers. If this flag is set, the access right is displayed on the basic security page only if the ISecurityInformation::GetObjectInformation method specifies the SI_CONTAINER flag.
    /// </summary>
    SI_ACCESS_CONTAINER = 0x00040000,
     
    /// <summary>
    /// Indicates a property-specific access right. Used with SI_EDIT_PROPERTIES.
    /// </summary>
    SI_ACCESS_PROPERTY = 0x00080000
}
 
public enum SI_CALLBACK_MESSAGE
{
    PSPCB_ADDREF = 0,
    PSPCB_RELEASE = 1,
    PSPCB_CREATE = 2,
    PSPCB_SI_INITDIALOG = 0x00401//WM_USER + 1
}
 
[Flags]
public enum SI_INHERIT_FLAGS
{
    CONTAINER_INHERIT_ACE,
    INHERIT_ONLY_ACE,
    OBJECT_INHERIT_ACE
}
 
/// <summary>
/// The SI_PAGE_TYPE enumeration contains values that indicate the types of property pages in an access control editor property sheet.
/// </summary>
[Flags]
public enum SI_PAGE_TYPE
{
    /// <summary>
    /// The basic security property page for editing the object's DACL.
    /// </summary>
    SI_PAGE_PERM,
     
    /// <summary>
    /// The Permissions tab for advanced editing of the object's DACL, such as editing object-specific ACEs.
    /// </summary>
    SI_PAGE_ADVPERM,
     
    /// <summary>
    /// The Auditing tab for editing the object's SACL.
    /// </summary>
    SI_PAGE_AUDIT,
     
    /// <summary>
    /// The Owner tab for editing the object's owner.
    /// </summary>
    SI_PAGE_OWNER,
     
    /// <summary>
    /// The Effective Permission tab that displays the effective permissions granted to a specified user or group for access to the object.
    /// </summary>
    SI_PAGE_EFFECTIVE,
     
    /// <summary>
    /// A dialog box for changing the owner of the object.
    /// </summary>
    SI_PAGE_TAKEOWNERSHIP
}

[StructLayout(LayoutKind.Sequential)]
public struct GENERIC_MAPPING
{
    public int GenericRead;
    public int GenericWrite;
    public int GenericExecute;
    public int GenericAll;
}
 
/// <summary>
/// The SI_OBJECT_INFO structure is used by the ISecurityInformation::GetObjectInformation method to specify information used to initialize the access control editor.
/// </summary>
[StructLayout(LayoutKind.Sequential)]
public struct SI_OBJECT_INFO
{
    /// <summary>
    /// A set of bit flags that determine the editing options available to the user. This member can be a combination of the following values.
    /// </summary>
    public SI_OBJECT_FLAGS dwFlags;
     
    /// <summary>
    /// Identifies a module that contains string resources to be used in the property sheet. The ISecurityInformation::GetAccessRights and ISecurityInformation::GetInheritTypes methods can specify string resource identifiers for display names.
    /// </summary>
    private IntPtr hInstance;
     
    /// <summary>
    /// A pointer to a null-terminated, Unicode string that names the computer on which to look up account names and SIDs. This value can be NULL to specify the local computer. The access control editor does not free this pointer.
    /// </summary>
    [MarshalAs(UnmanagedType.LPWStr)]
    public string szServerName;
     
    /// <summary>
    /// A pointer to a null-terminated, Unicode string that names the object being edited. This name appears in the title of the advanced security property sheet and any error message boxes displayed by the access control editor. The access control editor does not free this pointer.
    /// </summary>
    [MarshalAs(UnmanagedType.LPWStr)]
    public string szObjectName;
     
    /// <summary>
    /// A pointer to a null-terminated, Unicode string used as the title of the basic security property page. This member is ignored unless the SI_PAGE_TITLE flag is set in dwFlags. If the page title is not provided, a default title is used. The access control editor does not free this pointer.
    /// </summary>
    [MarshalAs(UnmanagedType.LPWStr)]
    public string szPageTitle;
     
    /// <summary>
    /// A GUID for the object. This member is ignored unless the SI_OBJECT_GUID flag is set in dwFlags.
    /// </summary>
    private IntPtr guidObjectType;
     
    public SI_OBJECT_INFO(SI_OBJECT_FLAGS flags, IntPtr hInstance, string servername, string objectname, string pagetitle)
    {
        dwFlags = flags;
        this.hInstance = hInstance;
        szServerName = servername;
        szObjectName = objectname;
        szPageTitle = pagetitle;
        guidObjectType = IntPtr.Zero;
    }
}
 
/// <summary>
/// The SI_ACCESS structure contains information about an access right or default access mask for a securable object. The ISecurityInformation::GetAccessRights method uses this structure to specify information that the access control editor uses to initialize its property pages.
/// </summary>
[StructLayout(LayoutKind.Sequential)]
public struct SI_ACCESS
{
    /// <summary>
    /// A pointer to a GUID structure that identifies the type of object to which the access right or default access mask applies. The GUID can identify a property set or property on the object, or a type of child object that can be contained by the object. If this member points to GUID_NULL, the access right applies to the object itself.
    /// </summary>
    private IntPtr pguid;
     
    /// <summary>
    /// A bitmask that specifies the access right described by this structure. The mask can contain any combination of standard and specific rights, but should not contain generic rights such as GENERIC_ALL.
    /// </summary>
    public SI_ACCESS_MASK mask;
     
    /// <summary>
    /// A pointer to a null-terminated Unicode string containing a display string that describes the access right. Alternatively, pszName can be a string resource identifier returned by the MAKEINTRESOURCE macro. Use the ISecurityInformation::GetObjectInformation method to identify the module that contains the string resource.
    /// </summary>
    [MarshalAs(UnmanagedType.LPWStr)]
    public string szName;
     
    /// <summary>
    /// A set of bit flags that indicate where the access right is displayed. This member can be a combination of the following.
    /// </summary>
    public SI_ACCESS_FLAG dwFlags;
     
    public static readonly int SizeOf = Marshal.SizeOf(typeof(SI_ACCESS));
     
    public SI_ACCESS(SI_ACCESS_MASK mask, string name, SI_ACCESS_FLAG flags)
    {
        pguid = IntPtr.Zero;
        this.mask = mask;
        szName = name;
        dwFlags = flags;
    }
}
 
/// <summary>
/// The SI_INHERIT_TYPE structure contains information about how access control entries (ACEs) can be inherited by child objects. The ISecurityInformation::GetInheritTypes method uses this structure to specify display strings that the access control editor uses to initialize its property pages.
/// </summary>
[StructLayout(LayoutKind.Sequential)]
public struct SI_INHERIT_TYPE
{
    /// <summary>
    /// A pointer to a GUID structure that identifies the type of child object. This member can be a pointer to GUID_NULL. The GUID corresponds to the InheritedObjectType member of an object-specific ACE.
    /// </summary>
    private IntPtr pguid;
     
    /// <summary>
    /// A set of inheritance flags that indicate the types of ACEs that can be inherited by the pguid object type. These flags correspond to the AceFlags member of an ACE_HEADER structure. This member can be a combination of the following values.
    /// </summary>
    public SI_INHERIT_FLAGS dwFlags;
 
    /// <summary>
    /// A pointer to a null-terminated Unicode string containing a display string that describes the child object.
    /// Alternatively, pszName can be a string resource identifier returned by the MAKEINTRESOURCE macro. Use the ISecurityInformation::GetObjectInformation method to identify the module that contains the string resource.
    /// </summary>
    [MarshalAs(UnmanagedType.LPWStr)]
    public string pszName;
}
/// <summary>
/// The ISecurityInformation interface enables the access control editor to communicate with the caller of the CreateSecurityPage and EditSecurity functions. The editor calls the interface methods to retrieve information that is used to initialize its pages and to determine the editing options available to the user. The editor also calls the interface methods to pass the user's input back to the application.
/// </summary>

/// <summary>
/// The ISecurityInformation interface enables the access control editor to communicate with the caller of the CreateSecurityPage and EditSecurity functions. The editor calls the interface methods to retrieve information that is used to initialize its pages and to determine the editing options available to the user. The editor also calls the interface methods to pass the user's input back to the application.
/// </summary>
[ComImport, InterfaceType(ComInterfaceType.InterfaceIsIUnknown), Guid("965FC360-16FF-11d0-91CB-00AA00BBB723")]
internal interface ISecurityInformation
{
    /// <summary>
    /// Requests information that is used to initialize the access control editor and to determine the editing options available to the user.
    /// </summary>
    ///<param name="pObjectInfo" />A pointer to an SI_OBJECT_INFO structure. Your implementation must fill this structure to pass information back to the access control editor.</param>
    void GetObjectInformation(ref SI_OBJECT_INFO pObjectInfo);
     
    /// <summary>
    /// Requests the security descriptor of the object being edited.
    /// </summary>
    /// <param name="RequestedInformation" />A set of SECURITY_INFORMATION bit flags that indicate the parts of the security descriptor being requested. This parameter can be a combination of the following values.</param>
    /// <param name="ppSecurityDescriptor" />A pointer to a variable that your implementation must set to a pointer to the object's security descriptor. The security descriptor must include the components requested by the RequestedInformation parameter. The system calls the LocalFree function to free the returned pointer.</param>
    /// <param name="fDefault" />If this parameter is TRUE, ppSecurityDescriptor should return an application-defined default security descriptor for the object. The access control editor uses this default security descriptor to reinitialize the property page. The access control editor sets this parameter to TRUE only if the user clicks the Default button. The Default button is displayed only if you set the SI_RESET flag in the ISecurityInformation::GetObjectInformation method. If no default security descriptor is available, do not set the SI_RESET flag. If this flag is FALSE, ppSecurityDescriptor should return the object's current security descriptor.</param>
    void GetSecurity(SI_SECURITY_INFORMATION RequestedInformation, IntPtr ppSecurityDescriptor, bool fDefault);
     
    /// <summary>
    /// Provides a security descriptor containing the security information specified by the user.
    /// </summary>
    /// <param name="SecurityInformation" />A set of SECURITY_INFORMATION bit flags that indicate the parts of the security descriptor to set. This parameter can be a combination of the following values.</param>
    /// <param name="pSecurityDescriptor" />A pointer to a security descriptor containing the new security information. Do not assume the security descriptor is in self-relative form; it can be either absolute or self-relative.</param>
    void SetSecurity(SI_SECURITY_INFORMATION SecurityInformation, IntPtr pSecurityDescriptor);
     
    /// <summary>
    /// Requests information about the access rights supported by the object being edited.
    /// </summary>
    /// <param name="pguidObjectType" />A pointer to a GUID structure that identifies the type of object for which access rights are being requested. If this parameter is NULL or a pointer to GUID_NULL, return the access rights for the object being edited. Otherwise, the GUID identifies a child object type returned by the ISecurityInformation::GetInheritTypes method. The GUID corresponds to the InheritedObjectType member of an object-specific ACE.</param>
    /// <param name="dwFlags" />A set of bit flags that indicate the property page being initialized. This value is zero if the basic security page is being initialized. Otherwise, it is a combination of the following values.</param>
    /// <param name="ppAccess" />A pointer to an array of SI_ACCESS structures. The array must include one entry for each access right. You can specify access rights that apply to the object itself, as well as object-specific access rights that apply only to a property set or property on the object.</param>
    /// <param name="pcAccesses" />A pointer to ULONG that indicates the number of entries in the ppAccess array.</param>
    /// <param name="piDefaultAccess" />A pointer to ULONG that indicates the zero-based index of the array entry that contains the default access rights. The access control editor uses this entry as the initial access rights in a new ACE.</param>
    void GetAccessRight(IntPtr pguidObjectType, SI_ACCESS_RIGHT_FLAG dwFlags, [MarshalAs(UnmanagedType.LPArray)]out SI_ACCESS[] ppAccess, ref uint pcAccesses, ref uint piDefaultAccess);
     
    /// <summary>
    /// Requests that the generic access rights in an access mask be mapped to their corresponding standard and specific access rights.
    /// </summary>
    /// <param name="pguidObjectType" />A pointer to a GUID structure that identifies the type of object to which the access mask applies. If this member is NULL or a pointer to GUID_NULL, the access mask applies to the object itself.</param>
    /// <param name="pAceFlags" />A pointer to the AceFlags member of the ACE_HEADER structure from the ACE whose access mask is being mapped.</param>
    /// <param name="pMask" />A pointer to an access mask that contains the generic access rights to map. Your implementation must map the generic access rights to the corresponding standard and specific access rights for the specified object type.</param>
    void MapGeneric(IntPtr pguidObjectType, IntPtr pAceFlags, IntPtr pMask);
     
    /// <summary>
    /// Requests information about how the object's ACEs can be inherited by child objects.
    /// </summary>
    /// <param name="ppInheritTypes" />A pointer to a variable you should set to a pointer to an array of SI_INHERIT_TYPE structures. The array should include one entry for each combination of inheritance flags and child object type that you support.</param>
    /// <param name="pcInheritTypes " />A pointer to a variable that you should set to indicate the number of entries in the ppInheritTypes array.</param>
    void GetInheritTypes(ref SI_INHERIT_TYPE ppInheritTypes, IntPtr pcInheritTypes);
     
    /// <summary>
    /// Notifies the application that an access control editor property page is being created or destroyed.
    /// </summary>
    /// <param name="hwnd" />If uMsg is PSPCB_SI_INITDIALOG, hwnd is a handle to the property page dialog box. Otherwise, hwnd is NULL.</param>
    /// <param name="uMsg" />Identifies the message being received. This parameter is one of the following values.</param>
    /// <param name="uPage" />A value from the SI_PAGE_TYPE enumeration type that indicates the type of access control editor property page being created or destroyed.</param>
    void PropertySheetPageCallback(IntPtr hwnd, int uMsg, SI_PAGE_TYPE uPage);
}
public abstract class SecurityEditor : ISecurityInformation
{
    /// <summary>
    /// The GetObjectInformation method requests information that the access control editor uses to initialize its pages and to determine the editing options available to the user.
    /// </summary>
    /// <param name="object_info" />A pointer to an SI_OBJECT_INFO structure. Your implementation must fill this structure to pass information back to the access control editor.</param>
    public abstract void GetObjectInformation(ref SI_OBJECT_INFO pObjectInfo);
     
    /// <summary>
    /// The GetAccessRights method requests information about the access rights that can be controlled for a securable object. The access control editor calls this method to retrieve display strings and other information used to initialize the property pages. For more information, see Access Rights and Access Masks.
    /// </summary>
    /// <param name="pguidObjectType" />A pointer to a GUID structure that identifies the type of object for which access rights are being requested. If this parameter is NULL or a pointer to GUID_NULL, return the access rights for the object being edited. Otherwise, the GUID identifies a child object type returned by the ISecurityInformation::GetInheritTypes method. The GUID corresponds to the InheritedObjectType member of an object-specific ACE.</param>
    /// <param name="dwFlags" />A set of bit flags that indicate the property page being initialized. This value is zero if the basic security page is being initialized. Otherwise, it is a combination of the following values. </param>
    /// <param name="ppAccess" />A pointer to an array of SI_ACCESS structures. The array must include one entry for each access right. You can specify access rights that apply to the object itself, as well as object-specific access rights that apply only to a property set or property on the object.</param>
    /// <param name="pcAccesses" />A pointer to ULONG that indicates the number of entries in the ppAccess array.</param>
    /// <param name="piDefaultAccess" />A pointer to ULONG that indicates the zero-based index of the array entry that contains the default access rights. The access control editor uses this entry as the initial access rights in a new ACE.</param>
    public abstract void GetAccessRight(IntPtr pguidObjectType, SI_ACCESS_RIGHT_FLAG dwFlags, out SI_ACCESS[] ppAccess, ref uint pcAccesses, ref uint piDefaultAccess);
     
    /// <summary>
    /// The GetSecurity method requests a security descriptor for the securable object whose security descriptor is being edited. The access control editor calls this method to retrieve the object's current or default security descriptor.
    /// </summary>
    /// <param name="RequestInformation" />A set of SECURITY_INFORMATION bit flags that indicate the parts of the security descriptor being requested. This parameter can be a combination of the following values.</param>
    /// <param name="ppSecurityDescriptor" />A pointer to a variable that your implementation must set to a pointer to the object's security descriptor. The security descriptor must include the components requested by the RequestedInformation parameter. The system calls the LocalFree function to free the returned pointer.</param>
    /// <param name="fDefault" />If this parameter is TRUE, ppSecurityDescriptor should return an application-defined default security descriptor for the object. The access control editor uses this default security descriptor to reinitialize the property page. The access control editor sets this parameter to TRUE only if the user clicks the Default button. The Default button is displayed only if you set the SI_RESET flag in the ISecurityInformation::GetObjectInformation method. If no default security descriptor is available, do not set the SI_RESET flag. If this flag is FALSE, ppSecurityDescriptor should return the object's current security descriptor.</param>
    public abstract void GetSecurity(SI_SECURITY_INFORMATION RequestInformation, IntPtr ppSecurityDescriptor, bool fDefault);
     
    /// <summary>
    /// The SetSecurity method provides a security descriptor containing the security information the user wants to apply to the securable object. The access control editor calls this method when the user clicks Okay or Apply.
    /// </summary>
    /// <param name="SecurityInformation" />A set of SECURITY_INFORMATION bit flags that indicate the parts of the security descriptor to set. This parameter can be a combination of the following values. </param>
    /// <param name="pSecurityDescriptor" />A pointer to a security descriptor containing the new security information. Do not assume the security descriptor is in self-relative form; it can be either absolute or self-relative.</param>
    public virtual void SetSecurity(SI_SECURITY_INFORMATION SecurityInformation, IntPtr pSecurityDescriptor)
    {
        _Store = true;
    }
     
    /// <summary>
    /// The GetInheritTypes method requests information about how ACEs can be inherited by child objects. For more information, see ACE Inheritance.
    /// </summary>
    /// <param name="ppInheritTypes" />A pointer to a variable you should set to a pointer to an array of SI_INHERIT_TYPE structures. The array should include one entry for each combination of inheritance flags and child object type that you support.</param>
    /// <param name="pcInheritTypes" />A pointer to a variable that you should set to indicate the number of entries in the ppInheritTypes array.</param>
    public virtual void GetInheritTypes(ref SI_INHERIT_TYPE ppInheritTypes, IntPtr pcInheritTypes)
    {
    }
     
    /// <summary>
    /// The PropertySheetPageCallback method notifies an EditSecurity or CreateSecurityPage caller that an access control editor property page is being created or destroyed.
    /// </summary>
    /// <param name="hwnd" />If uMsg is PSPCB_SI_INITDIALOG, hwnd is a handle to the property page dialog box. Otherwise, hwnd is NULL.</param>
    /// <param name="uMsg" />Identifies the message being received. This parameter is one of the following values.
    /// <param name="uPage" />A value from the SI_PAGE_TYPE enumeration type that indicates the type of access control editor property page being created or destroyed.</param>
    public virtual void PropertySheetPageCallback(IntPtr hwnd, int uMsg, SI_PAGE_TYPE uPage)
    {
    }
     
    /// <summary>
    /// The MapGeneric method requests that the generic access rights in an access mask be mapped to their corresponding standard and specific access rights. For more information about generic, standard, and specific access rights, see Access Rights and Access Masks.
    /// </summary>
    /// <param name="pguidObjectType" />A pointer to a GUID structure that identifies the type of object to which the access mask applies. If this member is NULL or a pointer to GUID_NULL, the access mask applies to the object itself.</param>
    /// <param name="pAceFlags" />A pointer to the AceFlags member of the ACE_HEADER structure from the ACE whose access mask is being mapped.</param>
    /// <param name="pMask" />A pointer to an access mask that contains the generic access rights to map. Your implementation must map the generic access rights to the corresponding standard and specific access rights for the specified object type.</param>
    public virtual void MapGeneric(IntPtr pguidObjectType, IntPtr pAceFlags, IntPtr pMask)
    {
        //MapGenericMask(pMask, ref _generic_mapping);
    }
     
    /// <summary>
    /// Shows the Security Editor as a modal dialog box with the specified owner.
    /// </summary>
    /// <param name="owner">Any object that implements Window that represents the top-level window that will own the modal dialog box. </param>
    /// <returns>TRUE if the user has changed the Security Descriptor, otherwise FALSE.</returns>
    public bool ShowDialog(IWin32Window owner)
    {
        // The type or namespace name 'WindowInteropHelper' could not be found 
        // EditSecurity((owner == null ? IntPtr.Zero : new WindowInteropHelper(owner).Handle), this);
         EditSecurity(IntPtr.Zero, this);
        return _Store;
    }
     
    #region Protected Area
     
    protected const uint SDDL_REVISION_1 = 1;
    protected const uint S_OK = 0;
    protected const uint E_ACCESSDENIED = 0x80070005;
     
    [DllImport("advapi32.dll")]
    protected static extern void MapGenericMask(IntPtr Mask, ref GENERIC_MAPPING map);
     
    [DllImport("advapi32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    protected static extern bool ConvertStringSecurityDescriptorToSecurityDescriptor([In] IntPtr pStringSd, [In] uint dwRevision, [In][Out] IntPtr pSecurityDescriptor, [Out] out uint SecurityDescriptorSize);
     
    [DllImport("advapi32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    protected static extern bool ConvertSecurityDescriptorToStringSecurityDescriptor(IntPtr SecurityDescriptor, uint StringSDRevision, SI_SECURITY_INFORMATION SecurityInformation, out IntPtr StringSecurityDescriptor, out uint StringSecurityDescriptorSize);
     
    #endregion
     
    #region Private Area
     
    [DllImport("aclui.dll")]
    private static extern bool EditSecurity(IntPtr hwnd, ISecurityInformation psi);
    private bool _Store = false;
     
    #endregion
}
 
public /* internal*/ class SDDLEditor : SecurityEditor
{
    public SDDLEditor(string sddl)
    {
        _SDDL = sddl;
    }
     
    public override void GetObjectInformation(ref SI_OBJECT_INFO pObjectInfo)
    {
        pObjectInfo = new SI_OBJECT_INFO(SI_OBJECT_FLAGS.SI_EDIT_PERMS | SI_OBJECT_FLAGS.SI_PAGE_TITLE,
                                         IntPtr.Zero, Environment.MachineName, "Object-Title", "Security");
    }
     
    public override void GetAccessRight(IntPtr pguidObjectType, SI_ACCESS_RIGHT_FLAG dwFlags, out SI_ACCESS[] ppAccess, ref uint pcAccesses, ref uint piDefaultAccess)
    {
        ppAccess = new SI_ACCESS[1];
        ppAccess[0] = new SI_ACCESS(SI_ACCESS_MASK.READ_CONTROL, "Full Access", SI_ACCESS_FLAG.SI_ACCESS_GENERAL);
        pcAccesses = (uint)ppAccess.Length;
        piDefaultAccess = 0;
    }
     
    public override void GetSecurity(SI_SECURITY_INFORMATION RequestInformation, IntPtr pSecurityDescriptor, bool fDefault)
    {
        if (RequestInformation == SI_SECURITY_INFORMATION.Dacl || RequestInformation == SI_SECURITY_INFORMATION.Sacl)
        {
            IntPtr pSDDL = IntPtr.Zero;
            try
            {
                pSDDL = Marshal.StringToHGlobalAuto(_SDDL);
                uint Size;
                if (!ConvertStringSecurityDescriptorToSecurityDescriptor(pSDDL, SDDL_REVISION_1, pSecurityDescriptor, out Size))
                    throw new ArgumentException("SDDL conversion failed, Error: " + Marshal.GetLastWin32Error());
            }
            finally
            {
                if (pSDDL != IntPtr.Zero)
                    Marshal.FreeHGlobal(pSDDL);
            }
        }
    }
     
    public override void SetSecurity(SI_SECURITY_INFORMATION SecurityInformation, IntPtr pSecurityDescriptor)
    {
        if (SecurityInformation == SI_SECURITY_INFORMATION.Dacl || SecurityInformation == SI_SECURITY_INFORMATION.Sacl)
        {
            IntPtr pSD;
            uint Size;
            if (!ConvertSecurityDescriptorToStringSecurityDescriptor(pSecurityDescriptor, SDDL_REVISION_1, SI_SECURITY_INFORMATION.Dacl, out pSD, out Size))
                throw new ArgumentException("SDDL conversion failed, Error: " + Marshal.GetLastWin32Error());
            _SDDL = Marshal.PtrToStringAuto(pSD);
            base.SetSecurity(SecurityInformation, pSecurityDescriptor);
        }
    }
     
    public string SDDL
    {
        get { return _SDDL; }
    }
     
    #region Private Area
     
    private string _SDDL;
     
    #endregion
}

"@ -ReferencedAssemblies 'System.Windows.Forms.dll'

Add-Type -TypeDefinition @"

// "
using System;
using System.Windows.Forms;
public class Win32Window : IWin32Window
{
    private IntPtr _hWnd;
    private string _data;

    public String Data
    {
        get { return _data; }
        set { _data = value; }
    }

    public Win32Window(IntPtr handle)
    {
        _hWnd = handle;
    }

    public IntPtr Handle
    {
        get { return _hWnd; }
    }
}

"@ -ReferencedAssemblies 'System.Windows.Forms.dll'


$sSDDL = "D:PARAI(A;;RC;;;LA)" 
$caller = New-Object -TypeName 'Win32Window' -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)
 
$sd_editor = new-object SDDLEditor($sSDDL)
$sd_editor.ShowDialog($caller)
 
Write-output $sd_editor.SDDL


# origin http://poshcode.org/6103
filter ConvertFrom-SDDL
{
<#
.SYNOPSIS

    Convert a raw security descriptor from SDDL form to a parsed security descriptor.
    Author: Matthew Graeber (@mattifestation)

.DESCRIPTION
    ConvertFrom-SDDL generates a parsed security descriptor based upon any string in raw security descriptor definition language (SDDL) form. ConvertFrom-SDDL will parse the SDDL regardless of the type of object the security descriptor represents.
.PARAMETER RawSDDL
    Specifies the security descriptor in raw SDDL form.
.EXAMPLE
    ConvertFrom-SDDL -RawSDDL 'D:PAI(A;;0xd01f01ff;;;SY)(A;;0xd01f01ff;;;BA)(A;;0x80120089;;;NS)'
.EXAMPLE
    'O:BAG:SYD:(D;;0xf0007;;;AN)(D;;0xf0007;;;BG)(A;;0xf0005;;;SY)(A;;0x5;;;BA)', 'O:BAG:SYD:PAI(D;OICI;FA;;;BG)(A;OICI;FA;;;BA)(A;OICIIO;FA;;;CO)(A;OICI;FA;;;SY)' | ConvertFrom-SDDL
.INPUTS
    System.String
    ConvertFrom-SDDL accepts SDDL strings from the pipeline
.OUTPUTS
    System.Management.Automation.PSObject
.LINK
    http://www.exploit-monday.com
#>

    Param (
        [Parameter( Position = 0, Mandatory = $True, ValueFromPipeline = $True )]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $RawSDDL
    )

    Set-StrictMode -Version 2

    # Get reference to sealed RawSecurityDescriptor class
    $RawSecurityDescriptor = [Int].Assembly.GetTypes() | ? { $_.FullName -eq 'System.Security.AccessControl.RawSecurityDescriptor' }

    # Create an instance of the RawSecurityDescriptor class based upon the provided raw SDDL
    try
    {
        $Sddl = [Activator]::CreateInstance($RawSecurityDescriptor, [Object[]] @($RawSDDL))
    }
    catch [Management.Automation.MethodInvocationException]
    {
        throw $Error[0]
    }

    if ($Sddl.Group -eq $null)
    {
        $Group = $null
    }
    else
    {
        $SID = $Sddl.Group
        $Group = $SID.Translate([Security.Principal.NTAccount]).Value
    }
    
    if ($Sddl.Owner -eq $null)
    {
        $Owner = $null
    }
    else
    {
        $SID = $Sddl.Owner
        $Owner = $SID.Translate([Security.Principal.NTAccount]).Value
    }

    $ObjectProperties = @{
        Group = $Group
        Owner = $Owner
    }

    if ($Sddl.DiscretionaryAcl -eq $null)
    {
        $Dacl = $null
    }
    else
    {
        $DaclArray = New-Object PSObject[](0)

        $ValueTable = @{}

        $EnumValueStrings = [Enum]::GetNames([System.Security.AccessControl.CryptoKeyRights])
        $CryptoEnumValues = $EnumValueStrings | % {
                $EnumValue = [Security.AccessControl.CryptoKeyRights] $_
                if (-not $ValueTable.ContainsKey($EnumValue.value__))
                {
                    $EnumValue
                }
        
                $ValueTable[$EnumValue.value__] = 1
            }

        $EnumValueStrings = [Enum]::GetNames([System.Security.AccessControl.FileSystemRights])
        $FileEnumValues = $EnumValueStrings | % {
                $EnumValue = [Security.AccessControl.FileSystemRights] $_
                if (-not $ValueTable.ContainsKey($EnumValue.value__))
                {
                    $EnumValue
                }
        
                $ValueTable[$EnumValue.value__] = 1
            }

        $EnumValues = $CryptoEnumValues + $FileEnumValues

        foreach ($DaclEntry in $Sddl.DiscretionaryAcl)
        {
            $SID = $DaclEntry.SecurityIdentifier
            $Account = $SID.Translate([Security.Principal.NTAccount]).Value

            $Values = New-Object String[](0)

            # Resolve access mask
            foreach ($Value in $EnumValues)
            {
                if (($DaclEntry.Accessmask -band $Value) -eq $Value)
                {
                    $Values += $Value.ToString()
                }
            }

            $Access = "$($Values -join ',')"

            $DaclTable = @{
                Rights = $Access
                IdentityReference = $Account
                IsInherited = $DaclEntry.IsInherited
                InheritanceFlags = $DaclEntry.InheritanceFlags
                PropagationFlags = $DaclEntry.PropagationFlags
            }

            if ($DaclEntry.AceType.ToString().Contains('Allowed'))
            {
                $DaclTable['AccessControlType'] = [Security.AccessControl.AccessControlType]::Allow
            }
            else
            {
                $DaclTable['AccessControlType'] = [Security.AccessControl.AccessControlType]::Deny
            }

            $DaclArray += New-Object PSObject -Property $DaclTable
        }

        $Dacl = $DaclArray
    }

    $ObjectProperties['Access'] = $Dacl

    $SecurityDescriptor = New-Object PSObject -Property $ObjectProperties

    Write-Output $SecurityDescriptor
}


