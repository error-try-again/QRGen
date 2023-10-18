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
    const {tabButton} = styles;
    return (
        <button onClick={() => handleTabChange(tab)}
                style={{...tabButton, borderBottom: activeTab === tab ? '2px solid rgb(129, 214, 255)' : 'none'}}>
            {label}
        </button>
    );
});
