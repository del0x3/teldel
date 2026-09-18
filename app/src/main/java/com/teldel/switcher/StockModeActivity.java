package com.teldel.switcher;

public class StockModeActivity extends BaseSwitcherActivity {
    @Override
    protected String getScriptPath() {
        return "/data/local/tmp/teldel_stock.sh";
    }

    @Override
    protected String getSuccessMessage() {
        return "Stock Mode Restored!";
    }
}
