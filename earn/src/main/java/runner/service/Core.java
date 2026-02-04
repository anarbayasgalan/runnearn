package runner.service;

import java.math.BigDecimal;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Date;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Component;
import runner.exception.RunnerException;

@Component
public class Core {

    public static boolean nullOrEmpty(String str) {
        return str == null || str.isEmpty();
    }

    public static boolean nullOrEmpty(List<?> list) {
        return list == null || list.isEmpty();
    }

    public static boolean nullOrEmpty(Object[] array) {
        return array == null || array.length == 0;
    }

    public static boolean nullOrEmpty(Map<?, ?> map) {
        return map == null || map.isEmpty();
    }

    public static boolean nullOrZero(Integer c) {
        return c == null || c.equals(0);
    }

    public static boolean nullOrZero(Long c) {
        return c == null || c.equals(0L);
    }

    public static boolean nullOrZero(BigDecimal c) {
        return c == null || c.compareTo(BigDecimal.ZERO) == 0;
    }

    public static LocalDateTime getNow() {
        return LocalDateTime.now();
    }

    public static boolean equal(String s1, String s2) {
        if (s1 == null && s2 == null) {
            return true;
        }

        if (s1 == null || s2 == null) {
            return false;
        }

        if (s1.equals(s2)) {
            return true;
        }

        return false;
    }

    public static boolean equal(Integer c1, Integer c2) {
        if (c1 == null && c2 == null) {
            return true;
        }

        if (c1 == null || c2 == null) {
            return false;
        }

        if (c1.equals(c2)) {
            return true;
        }

        return false;
    }

    public static boolean equal(Long c1, Long c2) {
        if (c1 == null && c2 == null) {
            return true;
        }

        if (c1 == null || c2 == null) {
            return false;
        }

        if (c1.equals(c2)) {
            return true;
        }

        return false;
    }

    public static boolean equal(BigDecimal c1, BigDecimal c2) {
        if (c1 == null && c2 == null) {
            return true;
        }

        if (c1 == null || c2 == null) {
            return false;
        }

        if (c1.equals(c2)) {
            return true;
        }

        return false;
    }

    public static String toString(Object val) {

        if (null == val)
            return "";

        String ret = null;
        Class<?> type = val.getClass();
        if (type == Date.class) {
            Date d = (Date) val;
            ret = toDateTimeStr(d);
        } else if (type == String.class) {
            ret = (String) val;
        } else {
            ret = String.valueOf(val);
        }

        return ret;
    }

    public static long toLong(Object val) {
        try {
            if (val == null)
                return 0L;

            Class<?> type = val.getClass();

            if (type == String.class)
                return Double.valueOf((String) val).longValue();
            else if (type == Integer.class)
                return (long) (Integer) val;
            else if (type == Byte.class)
                return (long) (Byte) val;
            else if (type == Long.class)
                return (Long) val;
            else if (type == BigDecimal.class)
                return ((BigDecimal) val).longValue();
            else if (type == Double.class)
                return ((Double) val).longValue();
            else if (type == Float.class)
                return ((Float) val).longValue();
            else if (type == Boolean.class)
                return (Boolean) val ? 1L : 0L;
            else {
                // Do nothing
            }

            return Double.valueOf(String.valueOf(val)).longValue();

        } catch (Exception e) {
            return 0l;
        }
    }

    public static int toInt(Object val) {
        try {
            if (val == null)
                return 0;

            Class<?> type = val.getClass();

            if (type == String.class)
                return Double.valueOf((String) val).intValue();
            else if (type == Integer.class)
                return (Integer) val;
            else if (type == Byte.class)
                return (int) (Byte) val;
            else if (type == Long.class)
                return ((Long) val).intValue();
            else if (type == BigDecimal.class)
                return ((BigDecimal) val).intValue();
            else if (type == Double.class)
                return ((Double) val).intValue();
            else if (type == Float.class)
                return ((Float) val).intValue();
            else if (type == Boolean.class)
                return (Boolean) val ? 1 : 0;
            else {
                // Do nothing
            }

            return Double.valueOf(String.valueOf(val)).intValue();

        } catch (Exception e) {
            return 0;
        }
    }

    public static String toDateTimeStr(Date date) {
        if (date == null) {
            return "0001-01-01 00:00:00";
        } else {
            DateFormat df = new SimpleDateFormat("yyyy-MM-dd");
            return df.format(date);
        }
    }

    public static void validate(boolean condition, int code, String message) {
        if (!condition) {
            throw new RunnerException(code, message);
        }
    }
}
