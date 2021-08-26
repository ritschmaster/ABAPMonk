# Mr **Monk** and **ABAP**

ABAP code needs to be formatted. Otherwise it is almost impossible to catch criminal bugs killing your daily SAP processes. Mr Monk will help us in this situation.

![ABAPMonk](abapmonk.jpg)

## Using ABAPMonk in Emacs

In your `.emacs` file you may define the following function:

    (defun my/abapmonk-on-region ()
      (interactive)
      (shell-command-on-region (region-beginning)
                               (region-end)
                               "abapmonk.pl"
                               (current-buffer)
                               t))

You can now use the function `my/abapmonk-on-region` with <kbd>M-x</kbd> after you have marked a region.

