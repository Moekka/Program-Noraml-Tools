

var internet_mode
var shell_obj
var g_ipv4_addr

function exec_cmd(cmd_str)
    //    var cmd_str = "ping 192.168.100.1"
    
    var ret = dllcall("rc:qs.dll", "char *", "Tcmd", "char *", cmd_str)
    
    return ret
end

function static_ip_change(source)
    var conn = combogettext("combobox1")
    var type = combogettext("combobox2")
    var ip_addr = editgettext("edit0")
    var mask = editgettext("edit1")
    var gateway = editgettext("edit2")
    var dns1 = editgettext("edit3")
    var dns2 = editgettext("edit4")
    var conn_str
    var type_str
    var cmd_str
    
    if(strcmp(conn,"本地") == 0)
        conn_str = "本地连接"
    else
        conn_str = "无线网络连接"
    end
    
    traceprint(conn)
    traceprint(type)
    
    if(strcmp(type,"增加") == 0)
        cmd_str = strformat("netsh interface ip add address name=\"%s\" addr=%s mask=%s",conn_str,ip_addr, mask)   
    elseif(strcmp(type,"删除") == 0)
        cmd_str = strformat("netsh interface ip delete address name=\"%s\" addr=%s",conn_str, ip_addr)
        var key = arrayfindvalue(g_ipv4_addr,ip_addr) 
        arraydeletepos(g_ipv4_addr,key)
        
    else
        cmd_str = strformat("netsh interface ip set address name=\"%s\" source=%s addr=%s mask=%s gateway=%s",conn_str, source, ip_addr, mask, gateway)
    end
    traceprint(cmd_str)
    exec_cmd(cmd_str)
end

function dynamic_ip_change(source)
    
end

function ip_change()
    var mode = combogettext("combobox0")
    traceprint(mode)
    if(strcmp(mode,"静态") == 0 )
        static_ip_change("static")
    else
        dynamic_ip_change("dhcp")
    end
end


//开始按钮_点击操作
function start_click()
    
    //    shell_obj=com("wscript.shell")
    
    ip_change()
    
end

//退出按钮_点击操作
function exit_click()
    
    exit()
end

function ipv4_address_show()
    var address
    var addr_array
    var count
    var cmd_str = "cmd /c ipconfig/all | findstr /c:\"IPv4 地址\""
    var str_buf
    var i
    address = exec_cmd(cmd_str)
    traceprint(address)
    addr_array = regexmatchtext(address,"((2[0-4]\\d|25[0-5]|[01]?\\d\\d?)\\.){3}(2[0-4]\\d|25[0-5]|[01]?\\d\\d?)",false,true,false,false)
    count = arraysize(addr_array)
    
    listdeleteall("list0")
    for(i = 0; i < count; i++)
        listaddtext("list0", addr_array[i])
    end
end

function button0_click()
    
    var ret
    var cmd_str = "cmd /c ipconfig/all | findstr /c:\"适配器\" | findstr /v /c:\"隧道\" | findstr /v /c:\"VMware\""
    var ret_val = dllcall("rc:qs.dll", "char *", "Tcmd", "char *", cmd_str)
    var retarr = regexmatchtext(ret_val,"( )[\\x{4e00}-\\x{9fa5}]+",false,true,true,false)
    var n = arraysize(retarr) 
    traceprint("count:" &n)
    
    for(var i=0;i < n;i++) 
        traceprint(retarr[i])
    end 
    //    
    //    
    //    var ret = dllcall("rc:qs.dll", "char *", "Tcmd", "char *", cmd_str)
    //    messagebox(exec_cmd(),"")
end

function thread_func()
    while(1)
        ipv4_address_show()
        sleep(1000)
    end
end

function connet_type_init()
    var ret
    var cmd_str = "cmd /c ipconfig/all | findstr /c:\"适配器\" | findstr /v /c:\"隧道\" | findstr /v /c:\"VMware\""
    var ret_val = dllcall("rc:qs.dll", "char *", "Tcmd", "char *", cmd_str)
    var retarr = regexmatchtext(ret_val,"( )[\\x{4e00}-\\x{9fa5}]+",false,true,true,false)
    var n = arraysize(retarr) 
    traceprint("count:" &n)
    
    for(var i=0;i < n;i++)
        comboaddtext("combobox1", retarr[i])
        traceprint(retarr[i])
    end
    combosetcursel("combobox1",1) 
end

function ipv4_address_init()
    var address
    var count
    var cmd_str = "cmd /c ipconfig/all | findstr /c:\"IPv4 地址\""
    
    address = exec_cmd(cmd_str)
    traceprint(address)
    g_ipv4_addr = regexmatchtext(address,"((2[0-4]\\d|25[0-5]|[01]?\\d\\d?)\\.){3}(2[0-4]\\d|25[0-5]|[01]?\\d\\d?)",false,true,false,false)
    count = arraysize(g_ipv4_addr)
    
    for(var i=0;i < count;i++)
        listaddtext("list0", g_ipv4_addr[i])
    end 
    
end

function 编程常用工具_init()
    
    ipv4_address_init()
    //    threadbegin("thread_func","") 
    
    connet_type_init()
end

//刷新
function button1_click()
    
    ipv4_address_show()
    
end

//添加地址
function button2_click()
    var cmd_str
    var ip_addr = editgettext("edit0")
    var mask = editgettext("edit1")
    var gateway = editgettext("edit2")
    var conn_str=combogettext("combobox1") 
    
    if(strcmp(ip_addr, "") == 0)
        messagebox("请输入正确的IP地址!","提示")
        return
    end
    if(strcmp(mask, "") == 0)
        messagebox("请输入正确的掩码!","提示")
        return
    end
    cmd_str = strformat("netsh interface ip add address name=\"%s\" addr=%s mask=%s",conn_str,ip_addr, mask)
    traceprint(cmd_str)
    exec_cmd(cmd_str)
    //    controlopenwindow("添加界面", true)
end

//删除地址
function button3_click()
    var cmd_str
    var ip_addr = listgetchecktext("list0")
    //    var id=listgetcursel("list0")
    var conn_str=combogettext("combobox1")
    
    
    //    listdeletetext("list0",id)
    cmd_str = strformat("netsh interface ip delete address name=\"%s\" addr=%s",conn_str, ip_addr)
    traceprint(cmd_str)
    exec_cmd(cmd_str)
end
