import {Tabs} from "../../ts/enums/tabs-enum";
import {styles} from "../../assets/styles";
import * as React from "react";
import {memo} from "react";

export const TabButtonComponent: React.FC<{
    activeTab: Tabs,
    tab: Tabs,
    label: string,
    handleTabChange: (freshTab: Tabs) => void,
    setTab: React.Dispatch<React.SetStateAction<Tabs>>
}> = (({activeTab, tab, label, handleTabChange}) => {
    const {tabButton} = styles;
    return (
        <button onClick={() => handleTabChange(tab)}
                style={{...tabButton, borderBottom: activeTab === tab ? '2px solid rgb(129, 214, 255)' : 'none'}}>
            {label}
        </button>
    );
});

TabButtonComponent.displayName = "TabButton";

export const TabButton = memo(TabButtonComponent);
