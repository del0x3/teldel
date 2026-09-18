package com.teldel.switcher;

public class MinimalModeActivity extends BaseSwitcherActivity {
    @Override
    protected boolean isStock() {
        return false;
    }

    @Override
    protected String getScriptPath() {
        return "/data/local/tmp/teldel_minimal.sh";
    }

    @Override
    protected String getSuccessMessage() {
        return "Minimal Mode Activated!";
    }
}
