from cookiecutter.utils import simple_filter
from datetime import datetime

@simple_filter
def embrace(s:str) -> str:
    """Enclose string with braces
    
    Useful to avoid lots of escaped braces in the template
    """
    return "{" + s + "}"

@simple_filter
def strftime(dts:str,format:str="%B %-d, %Y, %-i:%M %P") -> str:
    """Format datetime defined by a string"""
    return datetime.fromisoformat(dts).strftime(format)
    
@simple_filter
def localize_date(dts:str) -> str:
    """Format date according to local configuration"""
    d_format = "%B %-d, %Y"
    return datetime.fromisoformat(dts).strftime(d_format)

@simple_filter
def localize_datetime(dts:str) -> str:
    """Format date according to local configuration"""
    dt = datetime.fromisoformat(dts)
    dt_format = "%B %-d, %Y, %-i:%M %p"
    # Exception; am/pm should be lower case with periods,
    # contra en_US locale setting
    ampm = "p.m." if dt.hour > 12 else "a.m."
    # Warning: "%%p" in the format string will not cause an error.
    # That could be fixed with a regexp replace
    dt_format = dt_format.replace("%p",ampm)
    return dt.strftime(dt_format)
