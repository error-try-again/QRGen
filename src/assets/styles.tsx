import { CSSProperties } from 'react';

export const styles: { [key: string]: CSSProperties } = {
  bizCardsColumn: {
    flex: '1',
    minWidth: '300px'
  },
  bizCardsColumnMobile: {
    flex: '1',
    margin: '0 10px',
    minWidth: '300px',
    flexBasis: '100%'
  },
  dropdown: {
    border: '1px solid #ccc',
    borderRadius: '4px',
    fontSize: '16px',
    padding: '5px',
    width: '100%'
  },
  errorContainer: {
    backgroundColor: '#d78b8b',
    border: '1px solid red',
    borderRadius: '4px',
    padding: '10px',
    marginBottom: '20px',
    textAlign: 'center',
    fontWeight: 'bold'
  },
  fieldContainer: {
    display: 'flex',
    flexDirection: 'column',
    gap: '10px',
    marginBottom: '10px',
    width: '100%'
  },
  generateButton: {
    fontSize: '14px',
    padding: '8px 15px'
  },
  input: {
    borderRadius: '4px',
    fontSize: '16px',
    padding: '5px'
  },
  label: {
    fontSize: '14px',
    marginBottom: '5px'
  },
  notice: {
    color: 'red',
    marginBottom: '10px'
  },
  qrButtonsContainer: {
    display: 'flex',
    gap: '10px',
    marginBottom: '10px',
    width: '100%'
  },
  qrCodeContainer: {
    alignItems: 'center',
    display: 'flex',
    flexDirection: 'column',
    gap: '10px',
    marginTop: '20px'
  },
  renderBizCardsContainer: {
    display: 'flex',
    flexDirection: 'row',
    gap: '10px',
    marginBottom: '10px',
    width: '100%',
    justifyContent: 'space-between'
  },
  section: {
    marginBottom: '20px'
  },
  sectionTitle: {
    fontSize: '18px',
    marginBottom: '10px',
    textAlign: 'center'
  },
  tabButton: {
    padding: '5px 10px',
    margin: '2px',
    fontSize: '14px'
  },
  tabContainer: {
    flexWrap: 'wrap',
    gap: '5px',
    marginBottom: '10px',
    textAlign: 'initial'
  },
  themeContainer: {
    alignItems: 'center',
    display: 'flex',
    flexDirection: 'column',
    gap: '20px',
    margin: '0 auto',
    maxWidth: '400px',
    padding: '20px 0'
  },
  divider: {
    borderBottom: '1px solid #ccc',
    margin: '20px 0'
  },
  link: {
    color: '#646cff'
  }
};
