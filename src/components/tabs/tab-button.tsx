import {Tabs} from "../../ts/enums/tabs-enum.tsx";
import {styles} from "../../assets/styles.tsx";
import * as React from "react";

export const TabButton: React.FC<{
    activeTab: Tabs,
    tab: Tabs,
    label: string,
    handleTabChange: (freshTab: Tabs) => void,
    setTab: React.Dispatch<React.SetStateAction<Tabs>>
}> = React.memo(({activeTab, tab, label, handleTabChange}) => {
    return (
        <button onClick={() => handleTabChange(tab)}
                style={{...styles.tabButton, borderBottom: activeTab === tab ? '2px solid blue' : 'none'}}>
            {label}
        </button>
    );
});
