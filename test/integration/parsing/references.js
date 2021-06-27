import Parser from '../../../src/parser';

describe('.parse() coordinates', () => {
  let parser;
  let cellCoord;
  let startCellCoord;
  let endCellCoord;

  beforeEach(() => {
    parser = new Parser();

    parser.on('callReferenceValue', (_cellCoord, done) => {
      cellCoord = _cellCoord;
      done(55);
    });
    parser.on('callRangeValue', (_startCellCoord, _endCellCoord, done) => {
      startCellCoord = _startCellCoord;
      endCellCoord = _endCellCoord;
      done([[3, 6, 10]]);
    });
  });
  afterEach(() => {
    parser = null;
    cellCoord = null;
    startCellCoord = null;
    endCellCoord = null;
  });

  it('should parse relative cell', () => {
    expect(parser.parse('A1')).toMatchObject({error: null, result: 55});
    expect(cellCoord).toMatchObject({
      label: 'A1'
    });

    expect(parser.parse('a1')).toMatchObject({error: null, result: 55});
    expect(cellCoord).toMatchObject({
      label: 'a1'
    });
  });

  it('should parse named cell', () => {
    expect(parser.parse('@named_cell')).toMatchObject({error: null, result: 55});
    expect(cellCoord).toMatchObject({
      label: '@named_cell'
    });

    expect(parser.parse('@.named_cell')).toMatchObject({error: '#ERROR!', result: null});
  });

  it('should parse reference ranges', () => {
    expect(parser.parse('A1:B2')).toMatchObject({error: null, result: [[3, 6, 10]]});
    expect(startCellCoord).toMatchObject({
      label: 'A1'
    });
    expect(endCellCoord).toMatchObject({
      label: 'B2'
    });

    expect(parser.parse('a1:B2')).toMatchObject({error: null, result: [[3, 6, 10]]});
    expect(startCellCoord).toMatchObject({
      label: 'a1'
    });
    expect(endCellCoord).toMatchObject({
      label: 'B2'
    });

    expect(parser.parse('A1:b2')).toMatchObject({error: null, result: [[3, 6, 10]]});
    expect(startCellCoord).toMatchObject({
      label: 'A1'
    });
    expect(endCellCoord).toMatchObject({
      label: 'b2'
    });

    expect(parser.parse('a1:b2')).toMatchObject({error: null, result: [[3, 6, 10]]});
    expect(startCellCoord).toMatchObject({
      label: 'a1'
    });
    expect(endCellCoord).toMatchObject({
      label: 'b2'
    });
  });


  it('should parse named cells range', () => {
    expect(parser.parse('@NAMED_CELL1:@NAMED_CELL2')).toMatchObject({error: null, result: [[3, 6, 10]]});
    expect(startCellCoord).toMatchObject({
      label: '@NAMED_CELL1',
    });
    expect(endCellCoord).toMatchObject({
      label: '@NAMED_CELL2',
    });

    expect(parser.parse('@named_cell1:@named_cell2')).toMatchObject({error: null, result: [[3, 6, 10]]});
    expect(startCellCoord).toMatchObject({
      label: '@named_cell1',
    });
    expect(endCellCoord).toMatchObject({
      label: '@named_cell2',
    });

    expect(parser.parse('@named_cell1:named-cell2')).toMatchObject({error: '#VALUE!', result: null});
    expect(parser.parse('!named_cell1:@named_cell2')).toMatchObject({error: '#ERROR!', result: null});
  });
});
